


# box = acast(data, V2~V1, value.var= paste0("V",3))
#
# ret = array(NA, dim = c( dim(box), nbad))
#
#
# for (t in 1:nbad) {
#   box = acast(data, V2~V1, value.var= paste0("V",(t+2)))
#
#
#   if(any(is.na(box))){
#     datas<-melt(box)
#     for (i in 1:nrow(datas)) {
#       if (is.na(datas[i,3])){
#         datas[i,3] = mean(datas$value , na.rm = TRUE)
#       }
#     }
#     box = acast(datas, Var2~Var1, value.var= "value")
#   }
#   ret[,,t] = box
# }
#
#
#
# #convert this data frame into an array of dimentions (160, dim[1],dim[2])
# return(ret)


