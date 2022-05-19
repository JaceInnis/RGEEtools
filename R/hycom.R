










hycom = function(date = '20190101', scale = 160000, band = c('water_temp_0','water_temp_6','water_temp_12'
                                                             ,'water_temp_20','water_temp_30', 'velocity_u_0')
                 , interval = 15)
{


  date = lubridate::ymd(date)
  i_date = as.character(date-interval)
  f_date = as.character((date))


  nbad = length(band)

  velb = c()
  temb = c()

  for (i in 1:nbad) {
    if(str_detect(band[i], "velo")){
      velb = c(velb, band[i])
    }
    else{
      temb = c(temb, band[i])
    }
  }


  sea = ee$ImageCollection("HYCOM/sea_temp_salinity")$
    filterDate(i_date, f_date)$select(temb)$mean()$
    sample(region = ROI, scale = scale , geometries = TRUE , seed = 10)$getInfo()


  vel = ee$ImageCollection('HYCOM/sea_water_velocity')$
    filterDate(i_date, f_date)$select(velb)$mean()$
    sample(region = ROI, scale = scale , geometries = TRUE , seed = 10)$getInfo()


  #data = data.frame(lat = tabby[,1],lon =  tabby[,2])

  data = data.frame( )




  # create some check that will see if the number of points, their lat and long will match
  # up with not only the sea and vel but also the other dates that are being collected

  for (i in 1:length(sea$features[])) {
    data[i,1] =  sea$features[[i]]$geometry$coordinates[1]
    data[i,2] =  sea$features[[i]]$geometry$coordinates[2]

    unli = unlist(sea$features[[i]]$properties)
    for (w in 1:(length(temb))) {# five should be number of bands+3?
      data[i,w+2]  = unli[[w]]}

    unli = unlist(vel$features[[i]]$properties)
    for (w in 1:length(velb)) {
      data[i,(w+length(temb)+2)]  = unli[[w]]}
  }




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

}




#
#
# hycom = function(date = '20190101', scale = 160000, band = c('water_temp_0','water_temp_6','water_temp_12'
#                                                              ,'water_temp_20','water_temp_30', 'velocity_u_0')
#                  , interval = 15)
# {
#
#
#   date = lubridate::ymd(date)
#   i_date = as.character(date-interval)
#   f_date = as.character((date))
#
#
#   nbad = length(band)
#
#   velb = c()
#   temb = c()
#   sea = c()
#   vel = c()
#
#   for (i in 1:nbad) {
#     if(str_detect(band[i], "velo")){
#       velb = c(velb, band[i])
#     }
#     else{
#       temb = c(temb, band[i])
#     }
#   }
#
#   if(!is.null(temb)){
#     sea = ee$ImageCollection("HYCOM/sea_temp_salinity")$
#       filterDate(i_date, f_date)$select(temb)$mean()$
#       sample(region = ROI, scale = scale , geometries = TRUE , seed = 10)$getInfo()
#   }
#
#   if(!is.null(velb)){
#     vel = ee$ImageCollection('HYCOM/sea_water_velocity')$
#       filterDate(i_date, f_date)$select(velb)$mean()$
#       sample(region = ROI, scale = scale , geometries = TRUE , seed = 10)$getInfo()
#   }
#
#   #data = data.frame(lat = tabby[,1],lon =  tabby[,2])
#
#   data = data.frame( )
#
#
#   qr = 0
#
#   if(!is.null(sea)){
#     for (i in 1:length(vel$features[])) {
#       data[i,1] =  vel$features[[i]]$geometry$coordinates[1]
#       data[i,2] =  vel$features[[i]]$geometry$coordinates[2]
#
#       unli = unlist(vel$features[[i]]$properties)
#       for (w in 1:length(velb)) {
#         data[i,(w+2)]  = unli[[w]]}
#     }
#     qr = 1
#   }
#
#   if(!is.null(vel)){
#     for (i in 1:length(vel$features[])) {
#       data[i,1] =  vel$features[[i]]$geometry$coordinates[1]
#       data[i,2] =  vel$features[[i]]$geometry$coordinates[2]
#
#       unli = unlist(vel$features[[i]]$properties)
#       for (w in 1:length(velb)) {
#         data[i,(w+2)]  = unli[[w]]}
#     }
#     qr = 1
#   }
#
#
#   # create some check that will see if the number of points, their lat and long will match
#   # up with not only the sea and vel but also the other dates that are being collected
#   if(qr == 0){
#     for (i in 1:length(sea$features[])) {
#       data[i,1] =  sea$features[[i]]$geometry$coordinates[1]
#       data[i,2] =  sea$features[[i]]$geometry$coordinates[2]
#
#       unli = unlist(sea$features[[i]]$properties)
#       for (w in 1:(length(temb))) {# five should be number of bands+3?
#         data[i,w+2]  = unli[[w]]}
#
#       unli = unlist(vel$features[[i]]$properties)
#       for (w in 1:length(velb)) {
#         data[i,(w+length(temb)+2)]  = unli[[w]]}
#     }
#   }
#
#
#
#   box = acast(data, V2~V1, value.var= paste0("V",3))
#
#   ret = array(NA, dim = c( dim(box), nbad))
#
#
#   for (t in 1:nbad) {
#     box = acast(data, V2~V1, value.var= paste0("V",(t+2)))
#
#
#     if(any(is.na(box))){
#       datas<-melt(box)
#       for (i in 1:nrow(datas)) {
#         if (is.na(datas[i,3])){
#           datas[i,3] = mean(datas$value , na.rm = TRUE)
#         }
#       }
#       box = acast(datas, Var2~Var1, value.var= "value")
#     }
#     ret[,,t] = box
#   }
#
#
#
#   #convert this data frame into an array of dimentions (160, dim[1],dim[2])
#   return(ret)
#
# }

