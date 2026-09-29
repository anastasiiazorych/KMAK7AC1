print_table <- function(data, digits = 3, caption = "", scroll = 0) {
  data <- as.data.frame(data)

  if (digits >= 0) {
    numeric_columns <- vapply(data, is.numeric, logical(1))
    data[numeric_columns] <- lapply(
      data[numeric_columns],
      round,
      digits = digits
    )
  }

  align <- rep("c", ncol(data))
  
  tbl <- knitr::kable(
    data,
    format = "html",
    align = align,
    caption = caption,
    table.attr = 'class="table" style="width: auto; max-width: 100%; margin: 0 auto; table-layout: auto;"'
  )

  # Si scroll est un nombre positif, on applique la hauteur max en em
  if (is.numeric(scroll) && scroll > 0) {
    style <- sprintf("max-height: %sem; overflow-y: auto; overflow-x: auto; display: block;", scroll)
    tbl <- htmltools::HTML(sprintf('<div style="%s">%s</div>', style, tbl))
  }

  return(tbl)
}


get_script_dir <- function() {
  # 1. Cas Quarto (quarto render document.qmd, quel que soit l'éditeur)
  if (requireNamespace("knitr", quietly = TRUE) &&
      !is.null(knitr::current_input(dir = TRUE))) {
    return(dirname(knitr::current_input(dir = TRUE)))
  }
  
  # 2. Cas RStudio (chunk exécuté interactivement, ou script ouvert)
  if (requireNamespace("rstudioapi", quietly = TRUE) &&
      rstudioapi::isAvailable() &&
      rstudioapi::getActiveDocumentContext()$path != "") {
    return(dirname(rstudioapi::getActiveDocumentContext()$path))
  }
  
  # 3. Cas VSCode (extension vscode-R) : pas d'API équivalente à rstudioapi,
  #    mais l'extension place le wd sur le dossier du fichier lors d'un "Run Chunk"
  if (Sys.getenv("TERM_PROGRAM") == "vscode" ||
      Sys.getenv("VSCODE_PID") != "") {
    return(getwd())
  }
  
  # 4. Cas Rscript en ligne de commande
  args <- commandArgs(trailingOnly = FALSE)
  file_arg <- grep("^--file=", args, value = TRUE)
  if (length(file_arg) > 0) {
    return(dirname(sub("^--file=", "", file_arg)))
  }
  
  # 5. Fallback
  warning("Impossible de détecter le dossier du script, retour au working directory.")
  getwd()
}