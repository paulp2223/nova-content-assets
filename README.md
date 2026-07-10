# nova-content-assets

Public image assets for Vibeaholics / Nova content (reels, carousels, tweets).

**Start here:** [PLAYBOOK.md](PLAYBOOK.md) — the concept and full process (why we document sessions as
content, and how the whole idea → Notion → hosted visuals → reel pipeline works). [WORKFLOW.md](WORKFLOW.md)
is the short "how do I get an image in here" version.

**Why this repo is public:** Notion (and social) can only embed an image from a publicly reachable URL.
These are sanitized content visuals, no secrets, no private code.

## Layout
```
sessions/<YYYY-MM-DD>-<slug>/*.png    # cards + screenshots for one work session
```

## Referencing an asset in Notion
Each Notion "Ideas" entry references its assets two ways:
1. an inline external-image block (to eyeball on the page), and
2. a parseable `assets:` code block, e.g.
   `assets: ["https://raw.githubusercontent.com/paulp2223/nova-content-assets/main/sessions/2026-07-10-deslop-eval/01-score.png"]`
   so the reel-assembly step can pull them programmatically.

Raw URL pattern:
`https://raw.githubusercontent.com/paulp2223/nova-content-assets/main/<path>`
