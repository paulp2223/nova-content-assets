# Workflow — getting an image into the repo + Notion

Same destination for BOTH generated cards and your own real screenshots.

## 1. Put the image in a session folder
    sessions/<YYYY-MM-DD>-<slug>/<name>.png

## 2. Push it (helper does commit + push + prints the URL)
    ./add-asset.sh <path-to-image> <session-slug>
    # e.g. ./add-asset.sh ~/Desktop/notion-board.png 2026-07-10-deslop-eval
Manual equivalent: git add . && git commit -m "assets: ..." && git push

## 3. Public URL
    https://raw.githubusercontent.com/paulp2223/nova-content-assets/main/sessions/<slug>/<name>.png

## 4. Reference it on the Notion idea (Nova Drafts > Ideas)
    - add an external-image block with that URL (inline preview), and
    - append the URL to the page's `assets: [ ... ]` code block (so reel-assembly can pull it).

## Two producers
- **Generated cards** — ask Claude to render branded cards from session data; steps 1-4 automated.
- **Real screenshots** (Notion board, Excel, terminal, GitHub) — you capture, drop in the folder, run add-asset.sh, wire in Notion.
