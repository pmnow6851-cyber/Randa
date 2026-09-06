#!/usr/bin/env python3
"""RANDA.MKCOOL OS repository-side audit.

This script is intentionally read-only with respect to payment providers and the
production backend. It never receives or uses bank credentials, Stripe secret
keys, Supabase service-role keys, or customer records.
"""
from __future__ import annotations

import argparse
import datetime as dt
import re
import sys
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CANONICAL_URL = "https://pmnow6851-cyber.github.io/Randa/"
REQUIRED_FILES = [
    "index.html",
    "manifest.webmanifest",
    "service-worker.js",
    "PROJECT-STATUS.md",
    "README.md",
    ".nojekyll",
]

SECRET_PATTERNS = {
    "Stripe live secret": re.compile(r"sk_live_[A-Za-z0-9]{16,}"),
    "Stripe webhook secret": re.compile(r"whsec_[A-Za-z0-9]{16,}"),
    "Supabase secret": re.compile(r"sb_secret_[A-Za-z0-9_-]{16,}"),
    "Service-role assignment": re.compile(r"service_role\s*[:=]\s*[\"']?[A-Za-z0-9._-]{16,}", re.I),
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
PII_SCAN_EXCLUDES = {
    "README.md",
    "PROJECT-STATUS.md",
    "AI-HANDOFF.md",
    "docs/SECURITY-PRIVACY.md",
    "docs/OPERATIONS.md",
}


def tracked_text_files():
    for path in ROOT.rglob("*"):
        if not path.is_file() or ".git" in path.parts or path.suffix.lower() in TEXT_EXCLUDED_SUFFIXES:
            continue
        try:
            yield path, path.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            continue


def check_required(results):
    missing = [p for p in REQUIRED_FILES if not (ROOT / p).exists()]
    results.append(("Required production files", not missing, "OK" if not missing else f"Missing: {', '.join(missing)}"))


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
        if rel in PII_SCAN_EXCLUDES or rel.startswith("DAILY_AUDIT_REPORT"):
            continue
        for email in EMAIL_RE.findall(text):
            if email.lower().endswith("@example.com"):
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
    except Exception as exc:
        results.append(("Canonical endpoint uptime/state", False, f"Request failed: {type(exc).__name__}"))


def write_report(output: Path, results):
    now = dt.datetime.now(dt.timezone.utc).replace(microsecond=0).isoformat()
    passed = sum(1 for _, ok, _ in results if ok)
    failed = len(results) - passed
    overall = "PASS" if failed == 0 else "FAIL"
    lines = [
        "# RANDA.MKCOOL DAILY AUDIT REPORT",
        "",
        f"Generated: `{now}`",
        f"Overall: **{overall}**",
        f"Checks: **{passed} passed / {failed} failed**",
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
        "Automation may report, open incidents, update this report, and perform non-destructive health checks. It must not silently change price, payout destination, entitlement policy, calculation logic, authentication policy, or production secrets.",
        "",
    ]
    output.write_text("\n".join(lines), encoding="utf-8")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", default="DAILY_AUDIT_REPORT.md")
    args = parser.parse_args()

    results = []
    check_required(results)
    check_canonical_state(results)
    check_secrets(results)
    check_pii_literals(results)
    check_outbound_money_code(results)
    check_uptime(results)
    write_report(ROOT / args.output, results)

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
