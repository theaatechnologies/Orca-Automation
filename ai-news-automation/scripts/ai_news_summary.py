#!/usr/bin/env python3
import urllib.request
import xml.etree.ElementTree as ET
from datetime import datetime, timezone
from email.utils import parsedate_to_datetime
import re

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

ATOM_NS = {"atom": "http://www.w3.org/2005/Atom"}


def parse_date(raw):
    if not raw:
        return datetime.min.replace(tzinfo=timezone.utc)
    for fmt in (
        "%Y-%m-%dT%H:%M:%S%z",
        "%Y-%m-%dT%H:%M:%S.%f%z",
        "%a, %d %b %Y %H:%M:%S %z",
        "%a, %d %b %Y %H:%M:%S",
    ):
        try:
            dt = datetime.strptime(raw.strip(), fmt)
            if dt.tzinfo is None:
                dt = dt.replace(tzinfo=timezone.utc)
            return dt
        except ValueError:
            continue
    try:
        return parsedate_to_datetime(raw)
    except Exception:
        return datetime.min.replace(tzinfo=timezone.utc)


def fetch_rss(url):
    req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
    try:
        with urllib.request.urlopen(req, timeout=15) as resp:
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
            "date_parsed": parse_date(pub_date),
            "is_ai": is_ai,
        })
    return items


def parse_atom(xml_text, source_name):
    items = []
    try:
        root = ET.fromstring(xml_text)
    except ET.ParseError:
        return items
    for entry in root.findall("atom:entry", ATOM_NS):
        title_el = entry.find("atom:title", ATOM_NS)
        title = (title_el.text or "").strip() if title_el is not None else ""
        link_el = entry.find("atom:link[@rel='alternate']", ATOM_NS)
        if link_el is None:
            link_el = entry.find("atom:link", ATOM_NS)
        link = (link_el.get("href") or "").strip() if link_el is not None else ""
        published_el = entry.find("atom:published", ATOM_NS)
        updated_el = entry.find("atom:updated", ATOM_NS)
        pub_date = ""
        raw_date = ""
        if published_el is not None and published_el.text:
            raw_date = published_el.text.strip()
        elif updated_el is not None and updated_el.text:
            raw_date = updated_el.text.strip()
        pub_date = raw_date
        summary_el = entry.find("atom:summary", ATOM_NS)
        desc = (summary_el.text or "").strip() if summary_el is not None else ""
        if not title:
            continue
        combined = f"{title} {desc}"
        is_ai = bool(AI_KEYWORDS.search(combined))
        items.append({
            "source": source_name,
            "title": title,
            "link": link,
            "date": pub_date,
            "date_parsed": parse_date(raw_date),
            "is_ai": is_ai,
        })
    return items


def detect_and_parse(xml_text, source_name):
    if "<feed" in xml_text[:500] and "Atom" in xml_text[:1000]:
        return parse_atom(xml_text, source_name)
    return parse_rss(xml_text, source_name)


def main():
    all_items = []
    for src in SOURCES:
        print(f"Fetching {src['name']}...")
        xml_text = fetch_rss(src["url"])
        if xml_text:
            items = detect_and_parse(xml_text, src["name"])
            all_items.extend(items)
            print(f"  Found {len(items)} items")

    ai_items = [i for i in all_items if i["is_ai"]]
    if not ai_items:
        print("\nNo AI-specific items found. Falling back to latest items from all sources.")
        ai_items = all_items

    ai_items.sort(key=lambda x: x["date_parsed"], reverse=True)
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
