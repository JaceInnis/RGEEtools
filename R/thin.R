#' this is a function that will thin out the number of arrows in a vector plot
#'
#' @param df
#' @param by
#'
#' @return
#' @export
#'
#' @examples
#' vect = thin(df)
thin = function(df, by){
  df$n = 1:nrow(df)
  awr = filter(df, lon %in% (sort(unique(df$lon))
                             [seq(1, length(unique(df$lon)), by = by)])   &
                 lat %in% (sort(unique(df$lat))
                           [seq(1, length(unique(df$lat)), by = by)])) %>%
    pull(n)
  return(awr)
}

