#!/usr/bin/env bash
set -euo pipefail

SKIP_VERIFY=0
for arg in "$@"; do
  case "$arg" in
    --skip-verify) SKIP_VERIFY=1 ;;
    -h|--help)
      echo "Usage: $0 [--skip-verify]"
      exit 0
      ;;
    *)
      echo "Unknown option: $arg" >&2
      exit 2
      ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CALLER_PATH="$PATH"
OS="$(uname -s)"

case "$OS" in
  MINGW*|MSYS*|CYGWIN*)
    WIN_PS1="$SCRIPT_DIR/install-deps.ps1"
    if command -v cygpath >/dev/null 2>&1; then
      WIN_PS1="$(cygpath -w "$WIN_PS1")"
    fi
    if [ "$SKIP_VERIFY" -eq 1 ]; then
      exec powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$WIN_PS1" -SkipVerify
    else
      exec powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$WIN_PS1"
    fi
    ;;
esac

PACKAGES=(
  latexmk jsonparse nunito comfortaa fontawesome5
  geometry xcolor colortbl tcolorbox tikzfill
  pdfcol environ listings listingsutf8 pgf
  pgfplots hyperref rerunfilecheck uniquecounter
  ec cm-super fontaxes mweights figureversions
)

SENTINELS=(
  jsonparse.sty nunito.sty comfortaa.sty fontawesome5.sty
  geometry.sty xcolor.sty colortbl.sty tcolorbox.sty tikzfill.sty
  pdfcol.sty environ.sty listings.sty listingsutf8.sty pgf.sty
  pgfplots.sty hyperref.sty rerunfilecheck.sty uniquecounter.sty
  ecrm1000.tfm sfrm1000.pfb fontaxes.sty mweights.sty figureversions.sty
)

run_priv() {
  if [ "$(id -u)" -eq 0 ]; then
    "$@"
  elif command -v sudo >/dev/null 2>&1; then
    sudo "$@"
  else
    echo "Root privileges (or sudo) required to run: $*" >&2
    exit 1
  fi
}

prepend_path_if_dir() {
  if [ -d "$1" ]; then
    case ":$PATH:" in
      *":$1:"*) ;;
      *) export PATH="$1:$PATH" ;;
    esac
  fi
}

refresh_tex_paths() {
  prepend_path_if_dir "/opt/homebrew/bin"
  prepend_path_if_dir "/usr/local/bin"
  prepend_path_if_dir "$HOME/.local/bin"
  prepend_path_if_dir "$HOME/bin"
  prepend_path_if_dir "/Library/TeX/texbin"
  for d in "$HOME"/Library/TinyTeX/bin/* "$HOME"/.TinyTeX/bin/*; do
    prepend_path_if_dir "$d"
  done
}

have_all_sentinels() {
  command -v kpsewhich >/dev/null 2>&1 || return 1
  local f
  for f in "${SENTINELS[@]}"; do
    kpsewhich "$f" >/dev/null 2>&1 || return 1
  done
  return 0
}

install_tinytex() {
  local installer_url="https://yihui.org/tinytex/install-bin-unix.sh"
  mkdir -p "$HOME/.local/bin"
  echo "Installing TinyTeX (user-space TeX Live with current CTAN packages)..."
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$installer_url" | sh -s -- --no-path
  elif command -v wget >/dev/null 2>&1; then
    wget -qO- "$installer_url" | sh -s -- --no-path
  else
    echo "Neither curl nor wget is available to download TinyTeX." >&2
    exit 1
  fi
  refresh_tex_paths
}

install_linux_prereqs() {
  local need_install=0
  perl -mFile::Find /dev/null >/dev/null 2>&1 || need_install=1
  command -v xz >/dev/null 2>&1 || need_install=1
  command -v tar >/dev/null 2>&1 || need_install=1
  python3 -c "import json" >/dev/null 2>&1 || need_install=1
  if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
    need_install=1
  fi
  [ "$need_install" -eq 0 ] && return 0

  echo "Installing OS prerequisites..."
  if command -v apt-get >/dev/null 2>&1; then
    run_priv apt-get update -y
    run_priv apt-get install -y --no-install-recommends perl curl ca-certificates xz-utils tar fontconfig python3
  elif command -v dnf >/dev/null 2>&1; then
    run_priv dnf install -y perl perl-File-Find curl ca-certificates xz tar fontconfig python3
  elif command -v pacman >/dev/null 2>&1; then
    run_priv pacman -Sy --noconfirm --needed perl curl ca-certificates xz tar fontconfig python
  elif command -v zypper >/dev/null 2>&1; then
    run_priv zypper --non-interactive install perl curl ca-certificates xz tar fontconfig python3
  elif command -v apk >/dev/null 2>&1; then
    run_priv apk add --no-cache perl curl ca-certificates xz tar fontconfig python3
  else
    echo "Unsupported Linux package manager; install perl (with File::Find), curl, xz, tar, fontconfig, and python3 manually." >&2
    exit 1
  fi
}

refresh_tex_paths

case "$OS" in
  Linux)
    install_linux_prereqs
    ;;
  Darwin)
    if ! python3 -c "import json" >/dev/null 2>&1; then
      if command -v brew >/dev/null 2>&1; then
        brew install python
        refresh_tex_paths
      else
        echo "python3 not found. Install Xcode Command Line Tools (xcode-select --install) or Homebrew." >&2
        exit 1
      fi
    fi
    ;;
  *)
    echo "Unsupported OS: $OS" >&2
    exit 1
    ;;
esac

# Frozen distro TeX Live on LTS Linux releases lacks 2024+ jsonparse; fall back to TinyTeX when missing.
if ! command -v pdflatex >/dev/null 2>&1 || ! command -v latexmk >/dev/null 2>&1 || ! have_all_sentinels; then
  if ! command -v tlmgr >/dev/null 2>&1 && ! command -v miktex >/dev/null 2>&1; then
    if [ "$OS" = "Darwin" ] && command -v brew >/dev/null 2>&1; then
      echo "Installing BasicTeX via Homebrew..."
      brew install --cask basictex
      refresh_tex_paths
    else
      install_tinytex
    fi
  fi

  if command -v tlmgr >/dev/null 2>&1; then
    TL_ROOT="$(kpsewhich -var-value=SELFAUTOPARENT)"
    if [ -w "$TL_ROOT" ]; then
      tlmgr update --self
      tlmgr install "${PACKAGES[@]}"
      if [ "$OS" = "Linux" ]; then
        mkdir -p "$HOME/.local/bin"
        tlmgr option sys_bin "$HOME/.local/bin"
        tlmgr path add
      elif [ -w /usr/local/bin ]; then
        tlmgr path add
      fi
    else
      run_priv tlmgr update --self
      run_priv tlmgr install "${PACKAGES[@]}"
      run_priv tlmgr path add || true
    fi
    refresh_tex_paths
  elif command -v miktex >/dev/null 2>&1; then
    initexmf --set-config-value "[MPM]AutoInstall=1"
    miktex packages update-package-database
    for pkg in "${PACKAGES[@]}"; do
      miktex packages install "$pkg" || true
    done
    initexmf --update-fndb
    initexmf --mkmaps
    refresh_tex_paths
  fi
fi

if [ "$SKIP_VERIFY" -eq 0 ]; then
  LATEX_DIR="$REPO_ROOT/latex"
  python3 -m json.tool "$LATEX_DIR/data/baby.sample.json" >/dev/null

  TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/babybook-verify.XXXXXX")"
  trap 'rm -rf "$TMP_DIR"' EXIT
  printf '%s\n' '{"baby":{"name":"Anaya"}}' > "$TMP_DIR/smoke.json"
  printf '\\def\\smokedata{%s/smoke.json}\n' "$TMP_DIR" > "$TMP_DIR/smoke.tex"
  cat >> "$TMP_DIR/smoke.tex" <<'EOF'
\documentclass{babybook}
\loadbookdata{\smokedata}
\begin{document}
\pagetitle{Dependency Check}
\field{Name}{baby.name}
\end{document}
EOF
  echo "Verifying latexmk + pdflatex build..."
  (
    cd "$LATEX_DIR"
    latexmk -pdf -interaction=nonstopmode "-outdir=$TMP_DIR" "$TMP_DIR/smoke.tex" >/dev/null
  )
  [ -f "$TMP_DIR/smoke.pdf" ]
fi

PDF_BIN_DIR="$(dirname "$(command -v pdflatex)")"
case ":$CALLER_PATH:" in
  *":$PDF_BIN_DIR:"*) ;;
  *)
    echo "Note: add '$PDF_BIN_DIR' to your shell PATH (or open a new terminal) before building."
    ;;
esac

echo "All dependencies are installed and verified."
