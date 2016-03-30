# This sample gives an introduction to plotting using the ggplot2 package.

# The ggplot2 package is tremendously popular because it allows you to create
# beautiful plots by describing the plot structure

# R has a number of built-in datasets.
# In this example you use the dataset called quakes.
# This data contains locations of earthquakes off Fiji.

# Read the help page for more information
?quakes

# Inspect the structure of the data (a data frame with 5 columns)
str(quakes)

# install and load the packages
suppressWarnings(if (!require("ggplot2"))
    install.packages("ggplot2"))
library("ggplot2")
suppressWarnings(if (!require("rgl"))
    install.packages("rgl"))
library("rgl")
suppressWarnings(if (!require("mapproj"))
    install.packages("mapproj")) # required for map projections
library("mapproj")
# The package "gtable" allows you to work with objects called grob tables.
# A grob table captures all the information needed to layout grobs in a table
# structure. It supports row and column spanning, offers some tools to
# automatically figure out the correct dimensions, and makes it easy to align
# and combine multiple tables. 
suppressWarnings(if (!require("gtable"))
    install.packages("gtable"))
library(gtable)

# Plot longitude and latitude of quakes.
# To create a plot, you have to specify the data, then map aesthetics to 
# columns in your data. In this example, you map the column long to the x-axis
# and lat to the y-axis.
# Then you add a layer with points (geom_point) and a layer to plot maps.
p0 <- ggplot(quakes, aes(x = long, y = lat)) + 
    geom_point() + 
    coord_map()
p0 

# You can use a number of different aesthetics, for example colour or size
# of the points.

# Map the depth column to the colour aesthetic.
p1 <- ggplot(quakes, aes(x = long, y = lat)) + 
    geom_point(aes(colour = depth)) + 
    coord_map()
p1

# Add size for magnitude. The bigger the magnitude, the larger the point.
p2 <- ggplot(quakes, aes(x = long, y = lat)) + 
    geom_point(aes(colour = depth, size = mag)) + 
    coord_map()
p2

# You can control the transparancy of a plot object with the alpha aesthetic.
# High values of alpha (close to 1) are opaque, while low values (close to 0)
# are translucent.
# Add alpha level to hide overplotting, thus revealing detail.
p3 <- ggplot(quakes, aes(x = long, y = lat)) + 
    geom_point(aes(colour = depth, size = mag), alpha = 0.25) + 
    coord_map()
p3

# Change colour gradient by adding a gradient scale.
p4 <- ggplot(quakes, aes(x = long, y = lat)) + 
    geom_point(aes(colour = depth, size = mag), alpha = 0.25) + 
    coord_map() +
    scale_colour_gradient(low = "blue", high = "red")
p4

# Add a plot title
p5 <- ggplot(quakes, aes(x = long, y = lat)) + 
    geom_point(aes(colour = depth, size = mag), alpha = 0.25) + 
    scale_colour_gradient(low = "blue", high = "red") + 
    ggtitle("Distribution of earthquakes near Fiji") +
    coord_map()  
p5

# Now plot multiple plots on the same graphic
# The package "grid" is built into R and allows you to take control of the 
# plotting area. A grob is the abbreviation for "graphical object", and the 
# function ggplotGrob() in ggplot2 converts a ggplot2 object into a grob.
# You can then use the grid functions to combine your ggplot objects.

theme_set(theme_grey(12) + theme(legend.key.size  =  unit(0.5, "lines")))

library(grid)
plot.new()
grid.draw(cbind(
    ggplotGrob(p1), 
    ggplotGrob(p2),
    ggplotGrob(p3),
    size = "last"
    ))


plonglat <- ggplot(quakes, aes(x = long, y = lat, size = mag, col = depth)) +
    geom_point(alpha = 0.5) + 
    ggtitle("Top view")

plongdep <- ggplot(quakes, aes(x = long, y = -depth, size = mag, col = depth)) + 
    geom_point(alpha = 0.5) + 
    ggtitle("Side view")

platdep  <- ggplot(quakes, aes(x = depth, y = lat, size = mag, col = depth)) + 
    geom_point(alpha = 0.5) + 
    ggtitle("Side view")

# Next, define a gtable and add grobs to the table.
gt <- gtable(widths = unit(rep(1,2), "null"),
             heights = unit(rep(1,2), "null"))
gt <- gtable_add_grob(gt, 
                      grobs = list(
                        ggplotGrob(plonglat),
                        ggplotGrob(platdep),
                        ggplotGrob(plongdep)
                      ),
                      l  =  c(1, 2, 1), # left extent of the grobs
                      t  =  c(1, 1, 2)  # top extent of the grobs
)
plot.new()
grid.draw(gt)


# Finally, you can plot the data in an interactive 3D plot, using package rgl.
# Note this will open a seperate window with your plot.
# This window is interactive - you can click and drag in the window,
# thus changing the orientation of the data in 3 dimensions.
with(quakes, plot3d(lat, long, -depth, col = mag))


