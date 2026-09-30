print_table <- function(data, digits = 3, caption = "", scroll = 0, max.col.width = NULL) {
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

  # Unique container ID generation
  has_scroll <- is.numeric(scroll) && scroll > 0
  has_max_width <- !is.null(max.col.width)

  if (has_scroll || has_max_width) {
    container_id <- basename(tempfile(pattern = "tbl_"))
    css_style <- ""
    
    # Target all columns EXCEPT the first one using :not(:first-child)
    if (has_max_width) {
      width_str <- if (is.numeric(max.col.width)) sprintf("%spx", max.col.width) else max.col.width
      css_style <- sprintf(
        '<style>#%s th:not(:first-child), #%s td:not(:first-child) { max-width: %s; overflow-wrap: break-word; word-wrap: break-word; }</style>',
        container_id, container_id, width_str
      )
    }

    # Scroll container styling
    div_style <- ""
    if (has_scroll) {
      div_style <- sprintf(' style="max-height: %sem; overflow-y: auto; overflow-x: auto; display: block;"', scroll)
    }

    # Wrap inside container div
    tbl <- sprintf('<div id="%s"%s>%s%s</div>', container_id, div_style, css_style, tbl)
  }

  return(htmltools::HTML(tbl))
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