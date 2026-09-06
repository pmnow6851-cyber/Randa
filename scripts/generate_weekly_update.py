#!/usr/bin/env python3
"""Generate a small, deterministic weekly Aim Sync product/SEO update.

No paid AI/API is used. The generated page never exposes calculation logic or
paid sensitivity outputs.
"""
from __future__ import annotations

import datetime as dt
from html import escape
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "updates" / "index.html"
CANONICAL = "https://pmnow6851-cyber.github.io/Randa/"

TOPICS = [
    {
        "title": "CODM Sensitivity: Stop Chasing Random Settings",
        "lead": "If your aim changes every time you copy another setup, the problem is consistency, not a shortage of sensitivity numbers.",
        "body": "RANDA.MKCOOL Aim Sync keeps the focus on a repeatable device-and-input profile for Multiplayer and Battle Royale instead of endless setting swaps.",
        "keywords": "CODM Sensitivity, Aim Optimizer, MP sensitivity, BR sensitivity",
    },
    {
        "title": "Why Device Changes Can Affect CODM Aim Feel",
        "lead": "A new phone or tablet can change refresh rate, touch response, gyro behaviour, screen size, or input latency even before you touch your in-game sliders.",
        "body": "Aim Sync device support is reviewed when hardware changes are material enough to justify a new model classification or recalibration pass.",
        "keywords": "CODM Sensitivity, device calibration, gyroscope sensitivity, gaming phone",
    },
    {
        "title": "MP and BR Sensitivity Should Feel Like One System",
        "lead": "Players often tune Multiplayer and Battle Royale as two unrelated setups, then spend every session relearning their own controls.",
        "body": "RANDA.MKCOOL Aim Sync is designed around a consistent paid profile workflow for both modes while keeping the calculation engine private.",
        "keywords": "CODM Sensitivity, MP sensitivity, BR sensitivity, Aim Optimizer",
    },
    {
        "title": "FOV, Gyro and Sensitivity Are Part of the Same Feel",
        "lead": "Changing FOV or gyro use can make an otherwise familiar sensitivity profile feel different, especially across phones and tablets.",
        "body": "Aim Sync treats device and control context as part of the profile request rather than pretending one copied setup fits every player.",
        "keywords": "CODM Sensitivity, FOV settings, gyroscope sensitivity, sensitivity calculator",
    },
]


def main() -> None:
    now = dt.datetime.now(dt.timezone.utc)
    iso = now.isocalendar()
    topic = TOPICS[(iso.week - 1) % len(TOPICS)]
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)

    title = escape(topic["title"])
    lead = escape(topic["lead"])
    body = escape(topic["body"])
    keywords = escape(topic["keywords"])
    date = now.date().isoformat()

    html = f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <meta name="description" content="{lead}">
  <meta name="keywords" content="{keywords}">
  <link rel="canonical" href="{CANONICAL}updates/">
  <title>{title} | RANDA.MKCOOL Aim Sync</title>
  <style>
    body{{margin:0;background:#071018;color:#effbff;font-family:system-ui,-apple-system,Segoe UI,sans-serif}}
    main{{max-width:760px;margin:auto;padding:28px 18px 56px}}
    a{{color:#00e5ff}} .tag{{color:#8aa3b0;font-size:.8rem}} .card{{border:1px solid #1d3847;background:#0d1a24;border-radius:18px;padding:22px;margin-top:18px}}
    h1{{line-height:1.08}} p{{line-height:1.65;color:#c9dce4}}
  </style>
</head>
<body>
<main>
  <div class="tag">RANDA.MKCOOL AIM SYNC • WEEKLY UPDATE • {date}</div>
  <div class="card">
    <h1>{title}</h1>
    <p>{lead}</p>
    <p>{body}</p>
    <p><strong>Keywords:</strong> {keywords}</p>
    <p><a href="{CANONICAL}">Open the official RANDA.MKCOOL Aim Sync app</a></p>
  </div>
  <p class="tag">Unofficial CODM utility. Not affiliated with Activision, Tencent or TiMi Studio Group. Paid sensitivity outputs and calculation logic are not published here.</p>
</main>
</body>
</html>
"""
    OUTPUT.write_text(html, encoding="utf-8")
    print(f"Generated {OUTPUT.relative_to(ROOT)} for ISO week {iso.week}")


if __name__ == "__main__":
    main()
