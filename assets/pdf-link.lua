function Meta(meta)
  local input = PANDOC_STATE.input_files[1]
  
  -- Si le fichier termine par _cours.qmd
  if input and input:match("_cours%.qmd$") then
    local pdf_file = input:gsub("%.qmd$", ".pdf")
    
    local pdf_link = pandoc.MetaMap({
      text = pandoc.MetaString("Version PDF"),
      icon = pandoc.MetaString("file-pdf"),
      href = pandoc.MetaString(pdf_file)
    })
    
    if not meta['format-links'] then
      meta['format-links'] = pandoc.MetaList({ pdf_link })
    end
  end
  
  return meta
end