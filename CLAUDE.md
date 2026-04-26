# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Jing Zhao's personal academic portfolio site, built on the [academicpages](https://github.com/academicpages/academicpages.github.io) Jekyll template (forked and detached from Minimal Mistakes). Deployed to GitHub Pages at https://jzhao16.github.io.

Most "code" here is Jekyll content (Markdown + Liquid templates + SCSS), not application logic. The two non-Jekyll subsystems worth knowing about are the CV pipeline (`scripts/`) and the markdown generators (`markdown_generator/`, `talkmap.py`).

## Common commands

Local preview (after `bundle install`):
```bash
bundle exec jekyll serve -l -H localhost   # http://localhost:4000, live-reloads on .md/.html changes
```
`_config.yml` is **not** auto-reloaded — restart the server after editing it.

Docker alternative: `docker compose up` (also serves on `localhost:4000`).

JS bundle (only needed if `assets/js/_main.js` or vendor scripts change):
```bash
npm run build:js     # uglifies into assets/js/main.min.js
npm run watch:js     # rebuild on change
```

CV regeneration (after editing `_pages/cv.md`):
```bash
./scripts/update_cv_json.sh   # rewrites _data/cv.json from cv.md
```

Generate publication/talk markdown from TSV (rarely needed; prefer hand-editing the per-item `.md` files):
```bash
cd markdown_generator && python publications.py     # reads publications.tsv → _publications/*.md
cd markdown_generator && python talks.py            # reads talks.tsv → _talks/*.md
```

## Architecture

### Content collections
Configured in `_config.yml` under `collections:`. Each collection is a folder of Markdown files with YAML front matter; Jekyll renders one page per file.
- `_publications/` — one file per paper. `category:` front matter (e.g. `manuscripts`, `conferences`, `books`) groups them on the publications page; categories are defined in `_config.yml > publication_category`.
- `_talks/` — one file per talk. `location:` front matter is consumed by the talkmap pipeline (see below).
- `_teaching/`, `_portfolio/` — same pattern.
- `_posts/` — standard Jekyll blog posts.
- `_pages/` — top-level pages (about, cv, publications index, talks index, etc.). Navigation order is controlled by `_data/navigation.yml`.

### Layouts and includes
- `_layouts/` defines page shells (`single.html`, `archive.html`, `talk.html`, `cv-layout.html`, `splash.html`). The `defaults:` block in `_config.yml` maps each collection/page type to a default layout.
- `_includes/` holds reusable fragments. `archive-single.html` and `archive-single-talk.html` are the per-item renderers used by collection index pages — edits here change how every publication/talk row looks.
- `_sass/` is the SCSS source; the active theme is selected via `_config.yml > site_theme` (options: `default`, `air`, `sunrise`, `mint`, `dirt`, `contrast`).

### CV pipeline (custom, non-template)
The CV exists in two synchronized forms:
- `_pages/cv.md` — human-edited Markdown, source of truth.
- `_data/cv.json` — machine-readable form consumed by `_pages/cv-json.md` (and the `cv-template.html` / `cv-layout.html` includes/layouts) to render a structured CV view.

`scripts/cv_markdown_to_json.py` parses the Markdown's section headings and bullets into the JSON schema. Run `scripts/update_cv_json.sh` after editing `cv.md` so the two stay in sync. Don't hand-edit `cv.json`.

### Talkmap pipeline (automated)
`talkmap.ipynb` / `talkmap.py` scrapes `location:` front matter from `_talks/*.md`, geocodes via Nominatim, and writes a Leaflet cluster map into `talkmap/`. The GitHub Action `.github/workflows/scrape_talks.yml` runs this automatically on any push that touches `_talks/**` or `talkmap.ipynb`, and commits the regenerated `talkmap_out.ipynb` and map back to the branch — expect an automated follow-up commit after pushing talk changes.

## Editing conventions

- To add a publication/talk/portfolio item, create a new `.md` file under the relevant `_*/` folder following the front matter shape of existing entries. No build step needed — `jekyll serve` picks it up.
- Files in `files/` are served verbatim at `/files/<name>` (PDFs, slide decks, etc.).
- Images live in `images/`; reference as `/images/foo.png` from Markdown.
- The site is GitHub Pages safe-mode: only the plugins in `_config.yml > whitelist` are available. Don't add other gems expecting them to run on Pages.
