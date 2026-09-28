# Baby Record Book (LaTeX, A4)

From the first scan to five years: family tree, pregnancy, birth, growth charts, health, India (IAP) vaccines, teeth, milestones, months 1–12, holidays, letters and years 1–5.
Warm-paper editorial layout with colour-coded chapters, a pregnancy journey,
numbered milestone cards, and separate first-year / years 1–5 growth plots.

## Build

Needs a TeX distribution with `pdflatex` and `latexmk` (MiKTeX or TeX Live). Missing packages install on first run.

| Command | Result |
|---|---|
| `latexmk -pdf main.tex` | Your book if `data/baby.json` exists, otherwise the blank template |
| `latexmk -pdf template.tex` | Always the blank, print-and-fill template |
| `latexmk -pdf sample.tex` | Preview filled with `data/baby.sample.json` |

`latexmk -c` removes the helper files.
Generated PDFs, `data/baby.json` and photos are ignored by Git; only the
fictional example data is tracked.

## Fill it in digitally

1. Copy `data/baby.sample.json` to `data/baby.json` and edit it.
2. Put your photos in `photos/` and write only the file name in the JSON, e.g. `"photo": "scan_12wk.jpg"`.
3. Check the JSON: `python -m json.tool data/baby.json`. Then run `latexmk -pdf main.tex`.

Rules:

- A missing, empty or `null` key prints a blank line, so you can fill the book in gradually.
- Growth values (`growth.<age in months>`) are plain numbers in kg and cm. They feed the split 0–12 / 12–60 month growth charts, the growth log, the month pages and the year pages.
- `birth.delivery` is one of `natural`, `assisted`, `c-section`, `water`, `home`, `other`.
- `familyHistory.<condition>.mom` and `.dad` are `true` or `false` and show as ticks.
- Vaccines use `vaccines.<id>.{date,batch,notes}`. The ids are listed in `parts/04-growth-health.tex`. Add anything else to `vaccinesExtra[]`.
- Arrays such as `doctorVisits`, `illnesses`, `firstWords`, `pregnancy.checkups` and `pregnancy.predictions` fill the table rows and pad them with blanks.
- Missing photos show an empty frame.
- pdflatex handles Latin text only. `&`, `%`, `#` and `$` are fine, and `₹` prints as "Rs.". Use `\n` sparingly; it prints as a space.
- Tables don't break across pages, so keep long lists within the printed rows.

## Files

| File | What it holds |
|---|---|
| `babybook.cls` | Page layout, colours, fonts and drawing blocks (cards, fields, photos, family-tree nodes, tables) |
| `babydata.sty` | JSON loading (`jsonparse`) and the `\bbv`/`\bbget`/row helpers |
| `main.tex` | Entry point; lists the parts |
| `parts/00-front` … `07-years` | One file per section of the book |
| `data/baby.sample.json` | Full example and the reference for every key |
