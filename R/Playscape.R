library(RGEEtools)

start()



##### output list with data


hutolist = function(ROI, date ,interval , scale, band){
  date = lubridate::ymd(date)
  i_date = as.character(date-interval)
  f_date = as.character((date))

  data = ee$ImageCollection('HYCOM/sea_water_velocity')$
    filterDate(i_date, f_date)$select(band)$mean()$
    sample(region = ROI, scale = scale , geometries = TRUE)$getInfo()
  return(data)
}


###### output data frame with cord and data

geetodf = function(list){
  for (i in 1:length(list$features[])) {
    unli = unlist(list$features[[i]]$properties)
    te = list$features[[i]]$geometry$coordinates
    if(i == 1) {
      data = data.frame(lon = te[1], lat = te[2])
      for (j in 1:length(list$columns)) {
        data[[names(unli[j])]] = unli[[j]]
        }
      }
    else{
      data[i,] = c(te[1],te[2], rep(NA, length(list$columns)))
      for (j in 1:length(list$columns)) {
        data[i,j+2] = unli[[j]]
      }
    }
  }
  return(data)
}


###### output matrix of data
box = acast(data, V2~V1, value.var= paste0("V",3))

ret = array(NA, dim = c( dim(box), nbad))


for (t in 1:nbad) {
  box = acast(data, V2~V1, value.var= paste0("V",(t+2)))


  if(any(is.na(box))){
    datas<-melt(box)
    for (i in 1:nrow(datas)) {
      if (is.na(datas[i,3])){
        datas[i,3] = mean(datas$value , na.rm = TRUE)
      }
    }
    box = acast(datas, Var2~Var1, value.var= "value")
  }
  ret[,,t] = box
}



#convert this data frame into an array of dimentions (160, dim[1],dim[2])
return(ret)


