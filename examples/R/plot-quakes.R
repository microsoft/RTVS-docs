
str(quakes)


library(ggplot2)

# Plot longitude and latitude of quakes

p0 <- ggplot(quakes, aes(x=long, y=lat)) + 
  geom_point() + 
  coord_map()
p0 

# Add colour for depth

p1 <- ggplot(quakes, aes(x=long, y=lat)) + 
  geom_point(aes(colour=depth)) + 
  coord_map()
p1

# Add size for magnitude

p2 <- ggplot(quakes, aes(x=long, y=lat)) + 
  geom_point(aes(colour=depth, size=mag)) + 
  coord_map()
p2

# Add alpha level to hide overplotting, thus revealing detail

p3 <- ggplot(quakes, aes(x=long, y=lat)) + 
  geom_point(aes(colour=depth, size=mag), alpha=0.25) + 
  coord_map()
p3

# Change colour gradient

p4 <- ggplot(quakes, aes(x=long, y=lat)) + 
  geom_point(aes(colour=depth, size=mag), alpha=0.25) + 
  coord_map() +
  scale_colour_gradient(low="blue", high="red")
p4

# Add contour lines with stat_density2d

p5 <- ggplot(quakes, aes(x=long, y=lat)) + 
#   geom_density2d(colour="grey50") +
  geom_point(aes(colour=depth, size=mag), alpha=0.25) + 
  scale_colour_gradient(low="blue", high="red") + 
  ggtitle("Distribution of earthquakes near Fiji") +
  coord_map()  

p5


# All 5 plots on same graphic

# library(gridExtra)
# grid.layout(nrow=1, ncol=5)
# grid.arrange(p1, p2, p3, p4, p5, ncol=5, nrow=1)
# arrangeGrob


theme_set(theme_grey(12) + theme(legend.key.size = unit(0.5, "lines")))

library(gtable)
plot.new()
grid.draw(cbind(
  ggplotGrob(p1), 
  ggplotGrob(p2),
  ggplotGrob(p3),
  size="last"
))




plonglat <- ggplot(quakes, aes(x=long, y=lat, size=mag, col=depth)) + 
  geom_point(alpha=0.5) + 
  ggtitle("Top view")

plongdep <- ggplot(quakes, aes(x=long, y=-depth, size=mag, col=depth)) + 
  geom_point(alpha=0.5) + 
  ggtitle("Side view")

platdep  <- ggplot(quakes, aes(x=depth, y=lat, size=mag, col=depth)) + 
  geom_point(alpha=0.5) + 
  ggtitle("Side view")

gt <- gtable(widths=unit(rep(1,2), "null"),
             heights=unit(rep(1,2), "null"))
gt <- gtable_add_grob(gt, 
                      grobs=list(
                        ggplotGrob(plonglat),
                        ggplotGrob(platdep),
                        ggplotGrob(plongdep)
                      ),
                      l = c(1, 2, 1),
                      t = c(1, 1, 2)
)
plot.new()
grid.draw(gt)



# Plot in 3d, using rgl

library(rgl)
with(quakes, plot3d(lat, long, -depth, col=mag))


