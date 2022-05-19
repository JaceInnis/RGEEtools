






ROI = function( stri = "[117.83526716151925, 15.49233818000526],
          [117.83526716151925, 6.486174330165204],
          [129.74444684901925, 6.486174330165204],
          [129.74444684901925, 15.49233818000526]"){

  for (i in 1:40) {


    str_replace(stri, "\\[","c(") %>%
      str_replace("\\]","\\)") %>%
      str_replace("\n"," ") ->stri

  }

  stri =  paste0("list(",stri,")")

  stri = eval(parse(text = stri))

  ROI = ee$Geometry$Polygon(stri)

  Map$addLayer(ROI)

  return(ROI)
}
