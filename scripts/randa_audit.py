#!/usr/bin/env python3
"""RANDA.MKCOOL OS repository-side audit.

This script is intentionally read-only with respect to payment providers and the
production backend. It never receives or uses bank credentials, Stripe secret
keys, Supabase service-role keys, or customer records.
"""
from __future__ import annotations

import argparse
import datetime as dt
import json
import re
import subprocess
import sys
import urllib.error
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CANONICAL_URL = "https://pmnow6851-cyber.github.io/Randa/"
HEALTH_URL = "https://nnlckidhrsnodjulydpd.supabase.co/functions/v1/system-health"
REQUIRED_FILES = [
    "index.html",
    "manifest.webmanifest",
    "service-worker.js",
    "PROJECT-STATUS.md",
    "README.md",
    ".nojekyll",
    "robots.txt",
    "sitemap.xml",
    "docs/OPERATIONS.md",
    "docs/SECURITY-PRIVACY.md",
    "docs/RECOVERY-RUNBOOK.md",
    "docs/GROWTH-RUNBOOK.md",
]

SECRET_PATTERNS = {
    "Stripe live secret": re.compile(r"sk_live_[A-Za-z0-9]{16,}"),
    "Stripe test secret": re.compile(r"sk_test_[A-Za-z0-9]{16,}"),
    "Stripe webhook secret": re.compile(r"whsec_[A-Za-z0-9]{16,}"),
    "Supabase secret": re.compile(r"sb_secret_[A-Za-z0-9_-]{16,}"),
    "Service-role assignment": re.compile(r"service_role\s*[:=]\s*[\"']?[A-Za-z0-9._-]{16,}", re.I),
    "GitHub token": re.compile(r"\b(?:gh[pousr]_[A-Za-z0-9_]{20,}|github_pat_[A-Za-z0-9_]{20,})\b"),
    "OpenAI API secret": re.compile(r"\bsk-(?:proj|svcacct)-[A-Za-z0-9_-]{20,}\b"),
    "AWS access key": re.compile(r"\b(?:AKIA|ASIA)[A-Z0-9]{16}\b"),
    "Client-secret assignment": re.compile(r"client_secret\s*[:=]\s*[\"'][^\"']{12,}[\"']", re.I),
    "Private key": re.compile(r"-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----"),
}

OUTBOUND_MONEY_PATTERNS = {
    "Stripe refund creation": re.compile(r"(?:stripe\.)?refunds?\.create|/v1/refunds", re.I),
    "Stripe payout creation": re.compile(r"(?:stripe\.)?payouts?\.create|/v1/payouts", re.I),
    "Stripe transfer creation": re.compile(r"(?:stripe\.)?transfers?\.create|/v1/transfers", re.I),
}

EMAIL_RE = re.compile(r"\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b", re.I)
UK_PHONE_RE = re.compile(r"(?<!\d)(?:\+44\s?7\d{3}|07\d{3})[\s-]?\d{3}[\s-]?\d{3}(?!\d)")
UK_POSTCODE_RE = re.compile(r"\b(?:GIR\s?0AA|[A-Z]{1,2}\d[A-Z\d]?\s?\d[A-Z]{2})\b", re.I)

TEXT_EXCLUDED_SUFFIXES = {".png", ".jpg", ".jpeg", ".webp", ".gif", ".ico", ".zip"}
PII_SCAN_EXCLUDES = set()
TRUSTED_EMAIL_SUFFIXES = ("@example.com", "@users.noreply.github.com")
TRUSTED_EMAILS = set()

FORBIDDEN_TRACKED_NAME_PATTERNS = (
    re.compile(r"(^|/)\.env(?:\.|$)", re.I),
    re.compile(r"\.(?:pem|p12|pfx|jks|keystore|key)$", re.I),
    re.compile(r"(^|/)(?:key\.properties|service-account[^/]*\.json|firebase-admin[^/]*\.json|credentials[^/]*\.json|client_secret[^/]*\.json|google-services\.json|GoogleService-Info\.plist)$", re.I),
)

PROTECTED_CLIENT_FILES = ("index.html", "flutter_app/lib/main.dart", "service-worker.js")
PROTECTED_CLIENT_LOGIC_PATTERNS = {
    "scope coefficient": re.compile(r"\bscope[_\s-]?(?:multiplier|factor|coefficient)s?\b", re.I),
    "camera coefficient": re.compile(r"\bcamera[_\s-]?(?:multiplier|factor|coefficient)s?\b", re.I),
    "firing coefficient": re.compile(r"\bfiring[_\s-]?(?:multiplier|factor|coefficient)s?\b", re.I),
    "gyro coefficient": re.compile(r"\bgyro(?:scope)?[_\s-]?(?:multiplier|factor|coefficient)s?\b", re.I),
    "FOV coefficient": re.compile(r"\bfov[_\s-]?(?:multiplier|factor|coefficient)s?\b", re.I),
    "rotation coefficient": re.compile(r"\brotation[_\s-]?(?:multiplier|factor|coefficient)s?\b", re.I),
    "playstyle coefficient": re.compile(r"\bplaystyle[_\s-]?(?:multiplier|factor|coefficient)s?\b", re.I),
}


def tracked_relative_paths():
    try:
        raw = subprocess.run(
            ["git", "ls-files", "-z"],
            cwd=ROOT,
            check=True,
            capture_output=True,
        ).stdout.decode("utf-8", "replace")
    except (OSError, subprocess.CalledProcessError):
        return []
    return [rel for rel in raw.split("\0") if rel]


def tracked_text_files():
    for rel in tracked_relative_paths():
        path = ROOT / rel
        if not path.is_file() or path.suffix.lower() in TEXT_EXCLUDED_SUFFIXES:
            continue
        try:
            yield path, path.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            continue


def check_required(results):
    missing = [p for p in REQUIRED_FILES if not (ROOT / p).exists()]
    results.append(("Required production/operations files", not missing, "OK" if not missing else f"Missing: {', '.join(missing)}"))


def check_forbidden_tracked_files(results):
    hits = []
    for rel in tracked_relative_paths():
        if rel == ".env.example":
            continue
        if any(pattern.search(rel) for pattern in FORBIDDEN_TRACKED_NAME_PATTERNS):
            hits.append(rel)
    results.append((
        "Forbidden credential/signing files",
        not hits,
        "No forbidden tracked credential/signing files found" if not hits else "; ".join(sorted(set(hits))),
    ))



def check_workflow_security_policy(results):
    hits = []
    workflows = sorted((ROOT / ".github" / "workflows").glob("*.y*ml"))
    for path in workflows:
        rel = str(path.relative_to(ROOT))
        text = path.read_text(encoding="utf-8")

        if re.search(r"(?m)^\s*pull_request_target\s*:", text):
            hits.append(f"pull_request_target is forbidden in {rel}")
        if re.search(r"(?m)^\s*permissions\s*:\s*write-all\s*$", text):
            hits.append(f"write-all permissions found in {rel}")
        if re.search(r"(?m)^\s*contents\s*:\s*write\s*$", text):
            hits.append(f"contents: write found in {rel}")

        checkout_count = len(re.findall(r"uses:\s*actions/checkout@", text))
        hardened_checkout_count = len(re.findall(r"persist-credentials:\s*false", text))
        if hardened_checkout_count < checkout_count:
            hits.append(f"checkout persists credentials in {rel}")

        for match in re.finditer(r"uses:\s*([^\s#]+)", text):
            ref = match.group(1)
            if ref.startswith("./"):
                continue
            if "@" not in ref:
                hits.append(f"unversioned action in {rel}: {ref}")
                continue
            version = ref.rsplit("@", 1)[1]
            if not re.fullmatch(r"[0-9a-fA-F]{40}", version):
                hits.append(f"action is not pinned to a full commit SHA in {rel}: {ref}")

    results.append((
        "GitHub Actions supply-chain policy",
        not hits,
        "Actions are SHA-pinned, checkout credentials are disabled, and dangerous workflow triggers/permissions are absent"
        if not hits else "; ".join(hits),
    ))


def check_protected_client_logic(results):
    hits = []
    for rel in PROTECTED_CLIENT_FILES:
        path = ROOT / rel
        if not path.exists():
            continue
        text = path.read_text(encoding="utf-8")
        for label, pattern in PROTECTED_CLIENT_LOGIC_PATTERNS.items():
            if pattern.search(text):
                hits.append(f"{label} marker in {rel}")
    results.append((
        "Protected calculation logic stays server-side",
        not hits,
        "No protected coefficient/multiplier markers found in public clients" if not hits else "; ".join(hits),
    ))


def check_web_auth_storage(results):
    path = ROOT / "index.html"
    text = path.read_text(encoding="utf-8") if path.exists() else ""
    unsafe = (
        "localStorage.getItem(TOKEN_KEY)" in text
        or "localStorage.getItem(REFRESH_KEY)" in text
        or "localStorage.setItem(TOKEN_KEY" in text
        or "localStorage.setItem(REFRESH_KEY" in text
    )
    results.append((
        "Web auth tokens are not persisted in localStorage",
        not unsafe,
        "Auth tokens use session-scoped storage" if not unsafe else "Auth token persistence detected in localStorage",
    ))


def check_canonical_state(results):
    status = (ROOT / "PROJECT-STATUS.md").read_text(encoding="utf-8") if (ROOT / "PROJECT-STATUS.md").exists() else ""
    index = (ROOT / "index.html").read_text(encoding="utf-8") if (ROOT / "index.html").exists() else ""
    checks = {
        "LIVE_PAID_ONLY marker": "LIVE_PAID_ONLY" in status,
        "Canonical GitHub Pages URL": CANONICAL_URL in status,
        "Approved £9.99 price": "£9.99" in index,
        "Paid calculation endpoint": "calculate-aim-sync" in index,
        "Custom domain remains disabled": not (ROOT / "CNAME").exists(),
    }
    for name, ok in checks.items():
        results.append((name, ok, "OK" if ok else "FAILED"))


def check_seo(results):
    robots = (ROOT / "robots.txt").read_text(encoding="utf-8") if (ROOT / "robots.txt").exists() else ""
    sitemap = (ROOT / "sitemap.xml").read_text(encoding="utf-8") if (ROOT / "sitemap.xml").exists() else ""
    ok = f"{CANONICAL_URL}sitemap.xml" in robots and CANONICAL_URL in sitemap and "randa-aim-sync.com" not in sitemap
    results.append(("Canonical SEO files", ok, "robots/sitemap point to canonical GitHub Pages host" if ok else "SEO canonical/sitemap mismatch"))


def check_secrets(results):
    hits = []
    for path, text in tracked_text_files():
        rel = str(path.relative_to(ROOT))
        for label, pattern in SECRET_PATTERNS.items():
            if pattern.search(text):
                hits.append(f"{label} in {rel}")
    results.append(("High-risk secret scan", not hits, "No high-risk secrets found" if not hits else "; ".join(hits)))


def check_pii_literals(results):
    hits = []
    for path, text in tracked_text_files():
        rel = str(path.relative_to(ROOT))
        if rel in PII_SCAN_EXCLUDES or rel.startswith("DAILY_AUDIT_REPORT") or rel == "audit-log.md":
            continue
        for email in EMAIL_RE.findall(text):
            lowered = email.lower()
            if lowered in TRUSTED_EMAILS or lowered.endswith(TRUSTED_EMAIL_SUFFIXES):
                continue
            hits.append(f"email literal in {rel}")
            break
        if UK_PHONE_RE.search(text):
            hits.append(f"UK phone-like literal in {rel}")
        if UK_POSTCODE_RE.search(text):
            hits.append(f"UK postcode-like literal in {rel}")
    results.append(("Repository PII-literal scan", not hits, "No unexpected PII-like literals found" if not hits else "; ".join(sorted(set(hits)))))


def check_outbound_money_code(results):
    hits = []
    for rel in ("index.html", "service-worker.js"):
        path = ROOT / rel
        if not path.exists():
            continue
        text = path.read_text(encoding="utf-8")
        for label, pattern in OUTBOUND_MONEY_PATTERNS.items():
            if pattern.search(text):
                hits.append(f"{label} in {rel}")
    results.append(("Client outbound-money primitive scan", not hits, "No refund/payout/transfer creation primitives found" if not hits else "; ".join(hits)))


def check_uptime(results):
    try:
        req = urllib.request.Request(CANONICAL_URL, headers={"User-Agent": "RANDA-MKCOOL-OS-Audit/1.0"})
        with urllib.request.urlopen(req, timeout=25) as response:
            body = response.read(300000).decode("utf-8", "replace")
            code = response.status
        ok = code == 200 and "v5 PAID" in body and "£9.99" in body and "PAID ACCESS REQUIRED" in body
        results.append(("Canonical endpoint uptime/state", ok, f"HTTP {code}; paid markers {'present' if ok else 'missing'}"))
        return ok
    except Exception as exc:
        results.append(("Canonical endpoint uptime/state", False, f"Request failed: {type(exc).__name__}"))
        return False


def check_backend_health(results):
    try:
        req = urllib.request.Request(HEALTH_URL, headers={"User-Agent": "RANDA-MKCOOL-OS-Audit/1.0"})
        with urllib.request.urlopen(req, timeout=25) as response:
            payload = json.loads(response.read(100000).decode("utf-8", "replace"))
            code = response.status
        ok = code == 200 and payload.get("ok") is True
        results.append(("Payment/backend health", ok, f"HTTP {code}; {'ready' if ok else 'not ready'}"))
        return ok
    except urllib.error.HTTPError as exc:
        results.append(("Payment/backend health", False, f"HTTP {exc.code}; not ready"))
        return False
    except Exception as exc:
        results.append(("Payment/backend health", False, f"Request failed: {type(exc).__name__}"))
        return False


def update_audit_log(path: Path, timestamp: str, overall_ok: bool, uptime_ok: bool):
    header = [
        "# RANDA.MKCOOL AUDIT LOG",
        "",
        "Historical non-sensitive production health log generated by the daily GitHub Action.",
        "",
        "| UTC timestamp | Audit | Endpoint |",
        "|---|---|---|",
    ]
    if path.exists():
        lines = path.read_text(encoding="utf-8").splitlines()
    else:
        lines = header.copy()

    entry = f"| {timestamp} | {'PASS' if overall_ok else 'FAIL'} | {'UP' if uptime_ok else 'DOWN'} |"
    if not lines or lines[-1] != entry:
        lines.append(entry)
    path.write_text("\n".join(lines).rstrip() + "\n", encoding="utf-8")

    entries = [line for line in lines if re.match(r"^\| 20\d\d-", line)]
    up = sum("| UP |" in line for line in entries)
    pct = (up / len(entries) * 100.0) if entries else 0.0
    return pct, len(entries)


def write_report(output: Path, results, timestamp: str, uptime_pct: float, uptime_samples: int):
    passed = sum(1 for _, ok, _ in results if ok)
    failed = len(results) - passed
    overall = "PASS" if failed == 0 else "FAIL"
    lines = [
        "# RANDA.MKCOOL DAILY AUDIT REPORT",
        "",
        f"Generated: `{timestamp}`",
        f"Overall: **{overall}**",
        f"Checks: **{passed} passed / {failed} failed**",
        f"Recorded endpoint uptime: **{uptime_pct:.2f}% across {uptime_samples} audit sample(s)**",
        "",
        "## Results",
        "",
        "| Check | Status | Detail |",
        "|---|---|---|",
    ]
    for name, ok, detail in results:
        safe_detail = detail.replace("|", "\\|")
        lines.append(f"| {name} | {'PASS' if ok else 'FAIL'} | {safe_detail} |")
    lines += [
        "",
        "## Financial safety boundary",
        "",
        "This GitHub-side audit deliberately has **no bank credentials, Stripe secret key, Supabase service-role key, or customer transaction access**. It verifies that the public client does not contain code that creates refunds, payouts, or transfers. Authoritative payment/refund/chargeback state remains server-side with Stripe/Supabase and must not be copied into this public repository.",
        "",
        "## Privacy boundary",
        "",
        "This audit scans tracked repository text for accidental PII-like literals. It does not download or inspect customer records. Customer authentication/payment data must remain inside the approved service providers with least-privilege access and must never be written to GitHub logs.",
        "",
        "## Automation authority",
        "",
        "Automation may report, open incidents, update non-sensitive reports, and perform non-destructive health checks. It must not silently change price, payout destination, entitlement policy, calculation logic, authentication policy, production origins, or secrets.",
        "",
    ]
    output.write_text("\n".join(lines), encoding="utf-8")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", default="DAILY_AUDIT_REPORT.md")
    parser.add_argument("--log", default="audit-log.md")
    args = parser.parse_args()

    timestamp = dt.datetime.now(dt.timezone.utc).replace(microsecond=0).isoformat()
    results = []
    check_required(results)
    check_forbidden_tracked_files(results)
    check_workflow_security_policy(results)
    check_protected_client_logic(results)
    check_web_auth_storage(results)
    check_canonical_state(results)
    check_seo(results)
    check_secrets(results)
    check_pii_literals(results)
    check_outbound_money_code(results)
    app_ok = check_uptime(results)
    backend_ok = check_backend_health(results)
    uptime_ok = app_ok and backend_ok

    overall_ok = all(ok for _, ok, _ in results)
    uptime_pct, uptime_samples = update_audit_log(ROOT / args.log, timestamp, overall_ok, uptime_ok)
    write_report(ROOT / args.output, results, timestamp, uptime_pct, uptime_samples)

    failed = [name for name, ok, _ in results if not ok]
    if failed:
        print("Audit failed:")
        for name in failed:
            print(f" - {name}")
        return 1
    print("RANDA.MKCOOL OS audit passed")
    return 0


if __name__ == "__main__":
    sys.exit(main())
