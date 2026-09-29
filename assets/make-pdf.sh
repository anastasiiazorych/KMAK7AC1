#!/bin/bash

# 1. Détection de Chrome / Chromium
if command -v google-chrome &> /dev/null; then
  CHROME_BIN="google-chrome"
elif command -v chromium &> /dev/null; then
  CHROME_BIN="chromium"
elif command -v chromium-browser &> /dev/null; then
  CHROME_BIN="chromium-browser"
elif [ -f "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" ]; then
  CHROME_BIN="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
else
  echo "❌ ERREUR : Aucun navigateur Chrome ou Chromium trouvé."
  exit 1
fi

convert_one() {
  local target="$1"

  # Convertit l'extension si Quarto transmet le .qmd source
  if [[ "$target" == *.qmd ]]; then
    target="${target%.qmd}.html"
  fi

  # FILTRE STRICT : uniquement les fichiers se terminant par _cours.html
  if [[ "$target" == *"_cours.html" ]]; then
    if [ -f "$target" ]; then
      abs_html="$(realpath "$target")"
      pdf_file="${abs_html%.html}.pdf"

      echo "📄 Conversion PDF de : $abs_html"

      "$CHROME_BIN" \
        --headless=new \
        --no-sandbox \
        --disable-dev-shm-usage \
        --disable-gpu \
        --no-pdf-header-footer \
        --print-to-pdf="$pdf_file" \
        "file://$abs_html"

      if [ -f "$pdf_file" ]; then
        echo "✅ PDF créé : $pdf_file"
      fi
    else
      echo "⚠️ Fichier HTML introuvable : $target"
    fi
  fi
}

# 2. Exécution selon le mode d'appel de Quarto
if [ -n "$1" ]; then
  convert_one "$1"
elif [ -n "$QUARTO_PROJECT_OUTPUT_FILES" ]; then
  echo "$QUARTO_PROJECT_OUTPUT_FILES" | while IFS= read -r file; do
    convert_one "$file"
  done
elif [ -n "$QUARTO_RENDERED_FILE" ]; then
  convert_one "$QUARTO_RENDERED_FILE"
fi