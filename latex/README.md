# Baby Record Book (LaTeX, A4)

From the first scan to five years: family tree, pregnancy, birth, growth charts, health, India (IAP) vaccines, teeth, milestones, months 1–12, holidays, letters and years 1–5.

## Build

Needs a TeX distribution with `pdflatex` and `latexmk` (MiKTeX or TeX Live), plus Python 3 to validate JSON.

Install everything automatically from the repository root:

| OS | Command |
|---|---|
| Windows (PowerShell) | `powershell -ExecutionPolicy Bypass -File .\scripts\install-deps.ps1` |
| macOS / Linux | `./scripts/install-deps.sh` |

Then from `latex/`:

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
- Growth values (`growth.<age in months>`) are plain numbers in kg and cm. They feed the growth charts (plotted over WHO / IAP 3rd--97th percentile bands using `baby.sex` = `"girl"` or `"boy"`), the growth log, the month pages, the first-birthday page and the year pages.
- `birth.delivery` is one of `natural`, `assisted`, `c-section`, `water`, `home`, `other`.
- `familyHistory.<condition>.mom` and `.dad` are `true` or `false` and show as ticks.
- Vaccines use `vaccines.<id>.{date,batch,notes}` (or `vaccines.combo6w`, `combo10w`, `combo14w`, `combo18m` once for hexavalent/pentavalent shots). The ids are listed in `parts/04-growth-health.tex`. Add anything else to `vaccinesExtra[]`.
- Teeth use Universal primary dentition letters `teeth.<A..J>` (upper right to left) and `teeth.<K..T>` (lower left to right).
- Arrays such as `doctorVisits`, `illnesses`, `firstWords`, `pregnancy.checkups` and `pregnancy.predictions` fill the table rows and pad them with blanks.
- Ceremonies (`ceremonies.{naming,solids,haircut,piercing,letters,custom}`) each accept an optional custom `name` alongside `photo`, `date`, `place` and `notes`.
- Missing photos show an empty frame.
- `latexmk -pdf` (`pdflatex`) handles Latin text, smart quotes/dashes and prints `₹` as "Rs."; `latexmk -lualatex` (`lualatex`) supports full Unicode via `fontspec`. Pass `\documentclass[twoside]{babybook}` for inner/outer hardcover binding margins. Use `\n` sparingly; it prints as a space.
- Tables don't break across pages, so keep long lists within the printed rows.

## Files

| File | What it holds |
|---|---|
| `babybook.cls` | Page layout, colours, fonts and drawing blocks (cards, fields, photos, family-tree nodes, tables) |
| `babydata.sty` | JSON loading (`jsonparse`) and the `\bbv`/`\bbget`/row helpers |
| `main.tex` | Entry point; lists the parts |
| `parts/00-front` … `07-years` | One file per section of the book |
| `data/baby.sample.json` | Full example and the reference for every key |
