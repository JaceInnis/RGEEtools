#' Creates a ee.geometry object from a string of coordinate points copied from gee
#' @description Due to no map interface in the rgee version of gee, this function makes the importation of coordinate points easy. I have found that when exploring data in different regions, that having an open window of gee which allows for the easy creation of geometry objects and copying the coordinates into thos function
#'
#' @param stri a string of coordinate points copy and pasted from the gee gui
#'
#' @return
#' @export
#'
#' @examples
#' ROI = ROI("[-91.157, 28.628], [-91.157, 20.977], [-80.433, 20.977], [-80.434, 28.628]")
#'
ROI = function( stri = "[117.83526716151925, 15.49233818000526],
          [117.83526716151925, 6.486174330165204],
          [129.74444684901925, 6.486174330165204],
          [129.74444684901925, 15.49233818000526]"){

  for (i in 1:40) {
    stri =   stringr::str_replace(stri, "\\[","c(")
    stri =     stringr::str_replace(stri,"\\]","\\)")
    stri =     stringr::str_replace(stri, "\n"," ")
  }

  stri =  paste0("list(",stri,")")

  stri = eval(parse(text = stri))

  ROI = rgee::ee$Geometry$Polygon(stri)

  return(ROI)
}
