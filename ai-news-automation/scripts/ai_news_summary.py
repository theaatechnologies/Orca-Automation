#!/usr/bin/env python3
import urllib.request
import xml.etree.ElementTree as ET
from datetime import datetime, timezone
import re
import ssl

SOURCES = [
    {
        "name": "TechCrunch AI",
        "url": "https://techcrunch.com/category/artificial-intelligence/feed/",
    },
    {
        "name": "The Verge",
        "url": "https://www.theverge.com/rss/index.xml",
    },
    {
        "name": "MIT Tech Review",
        "url": "https://www.technologyreview.com/feed/",
    },
]

AI_KEYWORDS = re.compile(
    r"\b(ai|artificial.intelligence|machine.learning|deep.learning|llm|gpt|claude|gemini|neural|openai|anthropic|nvidia|chatgpt|copilot|transformer|foundation.model|agi|generative)\b",
    re.IGNORECASE,
)

def fetch_rss(url):
    ctx = ssl.create_default_context()
    ctx.check_hostname = False
    ctx.verify_mode = ssl.CERT_NONE
    req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
    try:
        with urllib.request.urlopen(req, timeout=15, context=ctx) as resp:
            return resp.read().decode("utf-8", errors="replace")
    except Exception as e:
        print(f"  [WARN] Failed to fetch {url}: {e}")
        return None

def parse_rss(xml_text, source_name):
    items = []
    try:
        root = ET.fromstring(xml_text)
    except ET.ParseError:
        return items
    channel = root.find("channel")
    entries = root.findall(".//item") if channel is None else channel.findall("item")
    for entry in entries:
        title = (entry.findtext("title") or "").strip()
        link = (entry.findtext("link") or "").strip()
        pub_date = (entry.findtext("pubDate") or "").strip()
        desc = (entry.findtext("description") or "").strip()
        if not title:
            continue
        combined = f"{title} {desc}"
        is_ai = bool(AI_KEYWORDS.search(combined))
        items.append({
            "source": source_name,
            "title": title,
            "link": link,
            "date": pub_date,
            "is_ai": is_ai,
        })
    return items

def main():
    all_items = []
    for src in SOURCES:
        print(f"Fetching {src['name']}...")
        xml_text = fetch_rss(src["url"])
        if xml_text:
            items = parse_rss(xml_text, src["name"])
            all_items.extend(items)
            print(f"  Found {len(items)} items")

    ai_items = [i for i in all_items if i["is_ai"]]
    if not ai_items:
        print("\nNo AI-specific items found. Falling back to latest items from all sources.")
        ai_items = all_items

    ai_items.sort(key=lambda x: x["date"], reverse=True)
    top = ai_items[:3]

    now = datetime.now(timezone.utc).strftime("%A, %B %d, %Y — %I:%M %p UTC")
    print(f"\n{'='*60}")
    print(f"  TOP 3 AI & TECH NEWS — {now}")
    print(f"{'='*60}\n")

    for idx, item in enumerate(top, 1):
        print(f"  {idx}. {item['title']}")
        print(f"     Source: {item['source']}")
        if item["link"]:
            print(f"     Link:   {item['link']}")
        if item["date"]:
            print(f"     Date:   {item['date']}")
        print()

    print(f"{'='*60}")

if __name__ == "__main__":
    main()
