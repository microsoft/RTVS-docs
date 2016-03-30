## Introduction to the ggplot2 plotting package

# The ggplot2 package is tremendously popular because it allows you to create
# beautiful plots by describing the plot structure.

# Install and load the packages.
#options(warn = -1)
suppressWarnings(
    if (!require("ggplot2", quietly = TRUE))
        install.packages("ggplot2", quiet = TRUE))
# mapproj is required for map projections.
suppressWarnings(
    if (!require("mapproj", quietly = TRUE))
        install.packages("mapproj", quiet = TRUE))
#options(warn = 0)

library("ggplot2", quietly = TRUE)
library("mapproj", quietly = TRUE)

# R has a number of built-in datasets.
# In this example you use the dataset called quakes.
# This data contains locations of earthquakes off Fiji.

# Read the help page for more information.
suppressWarnings(? quakes)

# Inspect the structure of the data (a data frame with 5 columns).
str(quakes)

# Set the font size so that it will be clearly legible.
theme_set(theme_gray(base_size = 18))

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

# Add a plot title.
p5 <- ggplot(quakes, aes(x = long, y = lat)) + 
    geom_point(aes(colour = depth, size = mag), alpha = 0.25) + 
    scale_colour_gradient(low = "blue", high = "red") + 
    ggtitle("Distribution of earthquakes near Fiji") +
    coord_map()  
p5

# Now plot multiple plots on the same graphic.
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


