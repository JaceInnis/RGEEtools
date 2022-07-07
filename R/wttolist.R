#' outputs list of water Temperate data with specified parameters
#' @description The point of this function is to extract data from a specific region (ROI), time (date), resolution (scale), avraged across a specified number of days (interval), from the HYCOM numerical model hosted on Google Earth Engine.
#' @param ROI an ee.geometry object, created by the ROI() function
#' @param date a string in "YYYYMMDD" format. (ultimate day of interval)
#' @param interval an integer to specify the number of days in the interval to average
#' @param scale  the resolution in meters that sampling takes place (must output less than 5000 points)
#' @param depth the depth at which the data will be pulled (read documentation for specified depths)
#'
#' @return
#' @export
#'
#' @examples
#' ROI = ROI()
#' list = wttolist(ROI, "20010928", 5, 30000, 10)
wttolist = function(ROI, date, interval, scale, depth){

  band =   paste0("water_temp_", depth)

  date = lubridate::ymd(date)
  i_date = as.character(date-interval)
  f_date = as.character((date))

  data = rgee::ee$ImageCollection('HYCOM/sea_temp_salinity')$
    filterDate(i_date, f_date)$select(band)$mean()$
    sample(region = ROI, scale = scale , geometries = TRUE, seed = 10)$getInfo()
  return(data)
}
