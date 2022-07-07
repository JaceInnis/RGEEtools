




vis = function(x = NA){

longData<-melt(x)
longData<-longData[longData$value!=0,]

ggplot(longData, aes(x = Var2, y = Var1)) +
  geom_raster(aes(fill=value)) +
  scale_fill_gradient(low="grey90", high="red") +
  labs(x="lat", y="lon")
}



