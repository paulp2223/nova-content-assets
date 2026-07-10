# Playbook — Content Visual Pipeline (Idea → Notion → hosted visuals → reel/post)

A repeatable pipeline for turning work sessions into publishable content: capture ideas, log
them in a Notion "Ideas" lane with enough grounding to draft from, attach branded visual cards
(or real screenshots), host the images publicly, and reference them in Notion so a later step can
assemble the reel/post. Project-agnostic — parameterize the vars in §8 for any project/server.

First built 2026-07-10 for Vibeaholics/Nova; generalized here.

---

## 0. Why this exists (the objective)

**The work is the content.** Vibeaholics is a founder (Paul) building useful tools in the open and
showing what they cost and whether they were worth it. Every real work session produces something no
competitor can fabricate — actual numbers, real failures, honest costs, genuine decisions. That
authenticity is the moat against AI slop and generic "build in public" fluff.

So the objective of this pipeline is to **systematically convert each work session into a bank of
grounded, on-brand content ideas plus the visual proof to make them real** — turning the receipts of
building in the open into reels, honestly and with proof. Concretely it exists so that:

- **Nothing valuable is lost.** Capture the ideas *and the material* (numbers, names, screenshots)
  while the session is fresh; a week later the specifics are gone.
- **Every idea is grounded, not abstract.** Real repos, real metrics, real screenshots → concrete
  drafts. (Thin context always produces abstract, forgettable content.)
- **The honest / counterintuitive moments are the point.** A regression, a feature you parked, a $1
  test that caught a mistake — these are the *highest-value* content because they're differentiated
  and credible. Wins-only "build in public" reads as marketing; the real story reads as trust.
- **It's on-brand and on-voice.** Ideas map to the content pillars (e.g. The Journey / Tips, Tricks &
  Tools / Curated / Vibes for Good) and the output follows the **same anti-slop voice discipline the
  tools themselves enforce** — which is why even the visual cards get de-slop-scrubbed (§4).

Everything below (§1-§9) is the *how*. This section is the *why* — if a step ever seems like busywork,
check it against this: does it make the session's real story easier to tell, with proof?

## Flow

    session work
       └─> IDEAS (Notion lane)  ── grounded idea entries
             └─> ASSETS (public git repo)  ── branded cards + real screenshots
                   └─> referenced back on the Notion idea (inline image + `assets:` block)
                         └─> assembled into the reel/post later

---

## 1. Notion "Ideas" lane

**Schema (Nova Drafts pattern):** `Name` (title) · `Pillar` (select) · `Status` (select — add an
`Ideas` option; a Kanban "lane" = a Status group) · `Source link` (url) · `Date` (date) ·
`Created time` (auto).

**An idea entry must be grounded, not just a narrative** (thin context → abstract drafts). Each page:
- 🎬 **HOOK** — the scroll-stopper line
- **ANGLE** — why it works / the perspective
- **KEY POINTS** — 3-5 talking points
- 📌 **MATERIAL** — the *real* specifics: exact numbers, names, repos, quotes, examples
- 🎥 **SUGGESTED ARC** — hook → setup → reveal → why → takeaway
- **On-screen moment** — the one visual beat

**API:** create with `POST /v1/pages` (`Status.select.name = "Ideas"`); append body blocks with
`PATCH /v1/blocks/{page_id}/children`. Gotcha: **Notion select option names can't contain commas**
(strip them). Skeleton in §9.

---

## 2. Notion constraints (know these before choosing storage)

- **Free plan: 5 MB per-file upload** (paid lifts it). Screenshots fit; video does not.
- **Files uploaded *into* Notion** are served back via the API as **signed URLs that expire (~1h)** →
  bad for automated "stitch it later" flows.
- **External image embeds** need a **publicly reachable URL** — Notion's servers must fetch it, so
  **tailnet-only / localhost / private-repo URLs won't render**.
- → **Store images externally at a public URL; put only a reference in Notion.** This sidesteps the
  size cap and the expiry entirely.

---

## 3. Image hosting — public assets repo

**Why public:** Notion must reach the URL, and the reels are public anyway. **Sanitize** (no keys,
no secrets, no sensitive paths).

- Use a **dedicated PUBLIC repo, separate from private code**. A *private* repo's
  `raw.githubusercontent.com` URLs are tokenized + expiring and Notion can't authenticate → won't
  render. So private repo = non-starter for embeds.
- **Layout:** `sessions/<YYYY-MM-DD>-<slug>/<name>.png`
- **GitHub limits:** 100 MB/file hard cap; ~1 GB soft repo size. Screenshots are ~1-2 MB → thousands
  fit. LFS only for >100 MB files.
- **Public raw URL:** `https://raw.githubusercontent.com/<user>/<repo>/main/sessions/<slug>/<name>.png`
- **Alternatives:** Cloudflare R2 (public bucket, *unguessable* paths, S3 API, free 10 GB — best when
  you want "not browsable" + automation) · Cloudinary (public + on-the-fly resize to 1:1 / 9:16) ·
  Notion-hosted upload (only if truly private + you'll stitch manually; accept 5 MB + expiring URLs).
- **Helper:** `add-asset.sh <image> <session-slug>` copies → commits → pushes → prints the raw URL
  (§9).

---

## 4. Generating branded cards (no browser required)

Turn real session data into 1080×1920 (reel) / 1080×1350 (carousel) branded PNGs.

- **Tooling:** `node` + **`@resvg/resvg-js`** (SVG→PNG) or **`satori`** (JSX→SVG). No headless
  browser, no PIL/matplotlib needed. On a locked-down host this is the reliable path.
- **Method:** hand-author an SVG string (full layout control) → render to PNG. Verify by **rendering
  then viewing the PNG** (catch overflow — keep copy short, no auto-wrap).
- **Fonts:** pass `fontFiles: [...]` (e.g. Mona Sans for headings, JetBrains Mono for numbers/terminal),
  `loadSystemFonts:false` for reproducibility.
- **APPLY THE DE-SLOP SCRUB to every card string** (consistency with the content voice):
  curly→straight quotes, strip invisible chars, **strip em/en/box dashes `— – ─`** (the em dash is the
  #1 AI tell). A plain `-` hyphen in a compound word ("anti-slop") is fine — it's not an em dash.
- **Templates that cover most cards:** `stat` (kicker + headline + big number + caption), `statement`
  (big two-line claim + mono line), `list` (bulleted takeaways), `terminal` (window chrome + real
  output), `bars` (grouped comparison).
- **Brand tokens (parameterize):** dark cover bg, cream headline, mono numbers, ONE accent (e.g. red
  for "bad"/green for "good"), a small footer mark. Render skeleton in §9.

---

## 5. Referencing in Notion (so it can be stitched later)

On each idea page add **two** things:
1. an **external-image block** (inline preview to eyeball), and
2. a **parseable `assets: [urls]` code block** (JSON) so the reel-assembly step can pull URLs
   programmatically.

---

## 6. Two producers, one destination

- **Generated cards** — render → push (`add-asset.sh`) → wire in Notion. Automatable end-to-end.
- **Real screenshots** (Notion board, spreadsheet, terminal, dashboards, GitHub) — you capture in the
  GUI → drop in the session folder → `add-asset.sh` → wire the same way. An agent can't screen-grab a
  GUI; it hosts + wires what you capture.

---

## 7. Common pitfalls (learned)

- Backgrounding a long job with `&` inside a wrapped shell call can orphan the child → use the
  runner's native background mode, not `&`.
- ESM `import` resolves relative to the **script file**, not the cwd → use absolute import paths for
  scripts run from elsewhere.
- Inline `node -e` with SVG/quotes gets mangled by the shell → write the script to a file (heredoc).
- Notion caches external images; updating a PNG at the same URL may show stale for a bit.
- `raw.githubusercontent.com` is not a CDN — fine for embedding, not for high-traffic serving.

---

## 8. Parameterize for a new project / server

| Var | Meaning |
|---|---|
| `NOTION_TOKEN` | Notion internal integration token — keep in the **project `.env`**, never in the public repo |
| `NOTION_DB_ID` | the Ideas database id |
| `ASSETS_REPO` | `<user>/<repo>` of the dedicated PUBLIC assets repo |
| `PILLARS` / `STATUS` | your select option names (the "Ideas" lane, your content pillars) |
| brand tokens | bg / text / accent colors, heading + mono fonts, logo mark |
| `SESSION_SLUG` | `<YYYY-MM-DD>-<topic>` |

**Host constraints checklist:** no headless browser → use resvg/satori. No PIL/matplotlib → SVG. On
macOS/launchd/no-sudo boxes, install tools user-space. **Tailnet/localhost URLs do NOT work for Notion
embeds** — must be public. **Never commit the Notion token** (public repo).

---

## 9. Snippets

**add-asset.sh**
```bash
#!/bin/bash
# add-asset.sh <image-path> <session-slug>
set -euo pipefail
IMG="$1"; SLUG="$2"; DIR="sessions/$SLUG"; BASE="$(basename "$IMG")"
mkdir -p "$DIR"; cp "$IMG" "$DIR/"
git add "$DIR/$BASE"; git commit -q -m "assets: add $BASE to $SLUG"; git push -q
echo "https://raw.githubusercontent.com/<USER>/<REPO>/main/$DIR/$BASE"
```

**Create a Notion Ideas entry (curl)**
```bash
curl -s https://api.notion.com/v1/pages \
  -H "Authorization: Bearer $NOTION_TOKEN" -H "Notion-Version: 2022-06-28" \
  -H "Content-Type: application/json" -d '{
    "parent": {"database_id": "'"$NOTION_DB_ID"'"},
    "properties": {
      "Name":   {"title":[{"text":{"content":"<idea title>"}}]},
      "Status": {"select":{"name":"Ideas"}},
      "Pillar": {"select":{"name":"<pillar (no commas)>"}}
    }}'
```

**Render a branded PNG card (node + @resvg/resvg-js)**
```js
import { Resvg } from '@resvg/resvg-js';
import fs from 'node:fs';
const W=1080,H=1920, BG='#0E0E10', CREAM='#F4ECD8', ACCENT='#FF6B6B';
// de-slop scrub — same rules as the content pipeline
const clean = s => String(s)
  .replace(/[“”„‟″]/g,'"').replace(/[‘’‚‛′]/g,"'")   // curly -> straight
  .replace(/[​‌‍⁠﻿­]/g,'') // invisibles
  .replace(/\s*[—–─]\s*/g,', ');                       // em/en/box dash -> comma
const esc = s => clean(s).replace(/&/g,'&amp;').replace(/</g,'&lt;');
const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="${W}" height="${H}">
  <rect width="${W}" height="${H}" fill="${BG}"/>
  <text x="72" y="380" font-family="Mona Sans" font-weight="800" font-size="84" fill="${CREAM}">${esc('Your headline')}</text>
  <text x="72" y="900" font-family="JetBrains Mono" font-size="140" fill="${CREAM}">${esc('49 → 38')}</text>
</svg>`;
const r = new Resvg(svg, { font: { fontFiles: ['MonaSans-ExtraBold.ttf','JetBrainsMono-Medium.ttf'], loadSystemFonts:false } });
fs.writeFileSync('card.png', r.render().asPng());
```

**Wire an asset onto a Notion idea (append blocks)**
```
PATCH /v1/blocks/{page_id}/children
children: [
  { heading_3: { rich_text:[{text:{content:"🖼 ASSETS"}}] } },
  { image: { type:"external", external:{ url:"<raw-url>" } } },
  { code:  { language:"json", rich_text:[{text:{content:'assets: ["<raw-url>"]'}}] } }
]
```
