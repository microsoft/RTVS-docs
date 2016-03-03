# ---	
# title: "6 - Plots"	
# author: "Joseph Rickert"	
# date: "Wednesday, August 20, 2014"	
# output: html_document	
# ---	
### Basic R Graphics	
# First, let's look at some simple scatter plots. The Duncan data frame has 45 rows and 4 columns. Data on the prestige and other characteristics of 45 U. S. occupations in 1950. 	

(if (!require("car")) install.packages("car"))
library("car") # Load the library containing the sample data	
(if (!require("ggplot2")) install.packages("ggplot2"))
library("ggplot2")
(if (!require("lattice")) install.packages("lattice"))
library("lattice")

class(Duncan)		# What kind of data structure is Duncan?	
dim(Duncan)			# How big is Duncan? 	
Duncan[1:5,]		# Look at the first five rows of the data frame	
plot(Duncan$education,Duncan$prestige)	


# Now, here is a truly ugly scatter plot. As an exercise, play with the parameters to creating something that is more pleasing to the eye. Here are a few web pages that you may find helpful.	
# http://www.statmethods.net/advgraphs/parameters.html	
# http://www.statmethods.net/graphs/scatterplot.html 	
# http://students.washington.edu/mclarkso/documents/line%20styles%20Ver2.pdf	

attach(Duncan)  	# make variables in data frame available in environment	
#	
plot(education,prestige,	
   main="Simple but ugly scatter plot", #add a title	
	 col="red",                  # Change the color of thepoints	
	 pch=15,                     # Change the symbol to plot  	
   cex=2,                      # Change size of plotting symbol   		
   xlab="EDUCATION",		       # Add a label on the x-axis	
	 ylab="PRESTIGE",            # Add a label on the y-axis	
	 bty="n",                    # Remove the box around the plot	
	 asp=1,                      # Change the y/x aspect ratio see help(plot)	
	 font.axis=4,                # Change axis font to bold italic	
	 col.axis="green",           # Change axia color to green	
	 las=1)                      # Make axis labels parallel to x-axis	
abline(lm(prestige~education), col="red") # regression line (y~x) 	
lines(lowess(prestige,education), col="blue") # lowess line (y~x)	
	
help(par)	

# Here is a nice example of putting multiple plots on a grid.   	

# Build more complicated scatter plots	
pairs(cbind(prestige,income,education),  	# pairs is function that produces a maatrix of scatter plots	
	panel=function(x,y){					# define a function panel for the content of the matrix 	
		points(x,y)							# plot the points	
		abline(lm(y~x), lty=2,col="blue")	# add a linear regression 	
		lines(lowess(x,y),col="red")		# add a nonlinear regression	
		},	
	diag.panel=function(x){					# define a new panel for the diagonals	
		par(new=T)	
		hist(x,main="",axes=F,nclass=12)	# put a histogram on each diagonal	
		}	
)	

# Here are a few more basic plots:	
#     - a simple histogram	
#     - a histogram with normal curve	
#     - a boxplot 	
#     - kernel density plot	

par(mfrow=c(2,2))  						# set up to draw multiple plots on the same chart	
# basic histogram	
hist(Duncan$prestige,xlab="prestige",col = "yellow",main="Histogram")	
#	
x <- rnorm(10000)							# random draw from normal distribution	
                              # plot histogram	
hist(x, freq = FALSE, col = "pink")				
curve(dnorm,								  # plot normal density	
	  col = "dark blue",				# set coor of curve	
	  lwd=2,								    # fill in the area under the curve	
	  add = TRUE)							  # add curve to existing plot	
# 	
boxplot(x,								  	# draw a boxplot	
	    col="yellow",							
		main="Box plot")							
# 	
plot(density(x),							# plot a kernel density estimate	
	 col="blue",							  # set the color	
	 type="h",								  # fill in the curve	
	 main="Kernel Density Estimate")		# add a title	
rug(x,col="red")                            	


## Lattice (trellis) Graphics	
# Lattice graphics are the second major plotting system in R. Plots built with
# lattice have a very distinctive look, but the real value is the ease of 
# making trellis plots - graphs that display a variable conditioned on an 
# other variable. Some useful websites are:	
# http://www.statmethods.net/advgraphs/trellis.html	
# http://user2007.org/program/presentations/sarkar.pdf   	

### Lattice Histograms	
histogram( ~ income | type, 	
	       data = Duncan,	
		   nint=5,	
           xlab = "Income",  	
		   main= "Hitogram by profession type",	
		   type = "density",	
           panel = function(x, ...) {	
              panel.histogram(x, ...)	
              panel.mathdensity(dmath = dnorm, col = "black",	
                                args = list(mean=mean(x),sd=sd(x)))	
          } )	
#	
# More histograms	
# using singer data	
histogram( ~ height | voice.part, data = singer,	
          xlab = "Height (inches)", type = "density",	
          panel = function(x, ...) {	
              panel.histogram(x, ...)	
              panel.mathdensity(dmath = dnorm, col = "black",	
                                args = list(mean=mean(x),sd=sd(x)))	
          } )	


### Lattice Density plots  	


densityplot( ~ height | voice.part, data = singer, layout = c(2, 4),  	
            xlab = "Height (inches)", bw = 5)  	
	
# Kernel density plot	
densityplot( ~ prestige | type, 	
	        data = Duncan, layout = c(3,1),  	
            xlab = "Income",	
			main= "Kernel Density plot",	
 			bw = 5,					# bandwidth parameter	
			col="dark blue",		# color	
			pch=2					# shape of plot symbol	
			)	


### Lattice Level Plots	

# Level plot	
levelplot(prestige ~ income*education, 	
       cuts = 15,	
       groups =  ,	
       data = Duncan,	
       main = " ",	
       sub = " ",	
       xlab = "income",	
       ylab = "education",	
       colorkey = TRUE,	
       contour = TRUE,	
       #layout = c(1, 1),	
       #xlim = c(, max(x)),	
       #ylim = c(min(y), max(y)),	
       )	
	
#	
# Fancy Level plot	
x <- seq(pi/4, 5 * pi, length.out = 100)	
y <- seq(pi/4, 5 * pi, length.out = 100)	
r <- as.vector(sqrt(outer(x^2, y^2, "+")))	
grid <- expand.grid(x=x, y=y)	
grid$z <- cos(r^2) * exp(-r/(pi^3))	
levelplot(z~x*y, grid, cuts = 50, scales=list(log="e"), xlab="",	
          ylab="", main="Weird Function", sub="with log scales",	
          colorkey = FALSE, region = TRUE)	
#	
# Another level plot	
attach(environmental)	
ozo.m <- loess((ozone^(1/3)) ~ wind * temperature * radiation,	
       parametric = c("radiation", "wind"), span = 1, degree = 2)	
w.marginal <- seq(min(wind), max(wind), length.out = 50)	
t.marginal <- seq(min(temperature), max(temperature), length.out = 50)	
r.marginal <- seq(min(radiation), max(radiation), length.out = 4)	
wtr.marginal <- list(wind = w.marginal, temperature = t.marginal,	
        radiation = r.marginal)	
grid <- expand.grid(wtr.marginal)	
grid[, "fit"] <- c(predict(ozo.m, grid))	
contourplot(fit ~ wind * temperature | radiation, data = grid,	
            cuts = 10, region = TRUE,	
            xlab = "Wind Speed (mph)",	
            ylab = "Temperature (F)",	
            main = "Cube Root Ozone (cube root ppb)")	
detach()	


### Some Miscellaneous Lattice Plots	

# Examples of 3 dimensional scatter plots	
## volcano  ## 87 x 61 matrix	
wireframe(volcano, shade = TRUE,	
          aspect = c(61/87, 0.4),	
          light.source = c(10,0,10))	
#-------------------------------------------------------------------------------------------	
# Wire Frame	
g <- expand.grid(x = 1:10, y = 5:15, gr = 1:2)	
g$z <- log((g$x^g$g + g$y^2) * g$gr)	
wireframe(z ~ x * y, data = g, groups = gr,	
          scales = list(arrows = FALSE),	
          drape = TRUE, colorkey = TRUE,	
          screen = list(z = 30, x = -60))	
	
#---------------------------------------------------------------------------------	
## cloud.table	
cloud(prop.table(Titanic, margin = 1:3),	
      type = c("p", "h"), strip = strip.custom(strip.names = TRUE),	
      scales = list(arrows = FALSE, distance = 2), panel.aspect = 0.7,	
      zlab = "Proportion")[, 1]	
#----------------------------------------------------------------------------------	
	

## GGPLOT2 GRAPHICS	
# ggplot is the third major plotting system for R.It is based on Leland Wilkinson's grammar of graphics. Plots are built in layers.	

# Some useful websites are:	
# http://www.cs.uic.edu/~wilkinson/TheGrammarOfGraphics/GOG.html	
# http://ggplot2.org/	
# http://docs.ggplot2.org/current/	
# http://www.cookbook-r.com/Graphs/	

# Here we illustrate building up a multi-layer plot	

# Scatter plot	
p <- ggplot(Duncan, aes(income, prestige))  					# data to be plotted	
# p		# This will produce an error since no layers are defined														
layer1 <- geom_point(shape = 2,colour="red")					# First layer specifies kind of plot	
p + layer1							
layer2 <- facet_wrap(~ type)									        # Second layer builds facet plot	
p + layer1 + layer2	
layer3 <- geom_smooth(aes(group=type),method="lm",size=1,se=F)	# Third layer add a regression line	
p + layer1 + layer2 + layer3	
layer4 <- ggtitle("Duncan Prestige Data")						   # Fourth layer add a title	
p + layer1 + layer2 + layer3 + layer4	


### Basic ggplot2 Histogram	

p <- ggplot(Duncan,aes(income))	
p + geom_histogram(binwidth=10)	


### ggplot Scatterplot	

set.seed(1410) # Make the sample reproducible	
dsmall <- diamonds[sample(nrow(diamonds), 500), ]	
p <- ggplot(dsmall, aes(carat, price))	
p + geom_point() + stat_smooth()	
# Same plot with alternate "simple" plot function qplot	


### qplot examples	
# The ggplot2 package also has a function called qplot which is often simpler to use	
# However, it has a different syntax than the ggplot function.	

qplot(carat, price, data = diamonds, geom = c("point", "smooth"))	
	
# Mapping point colour to diamond colour (left), and point shape to cut	
# quality (right).	
qplot(carat, price, data = dsmall, colour = color)	
qplot(carat, price, data = dsmall, shape = cut)	
#	
# Reducing the alpha value from 1/10 (left) to 1/100 (middle) to 1/200	
# (right) makes it possible to see where the bulk of the points lie.	
qplot(carat, price, data = diamonds)	
qplot(carat, price, data = diamonds, alpha = I(1/10))	
qplot(carat, price, data = diamonds, alpha = I(1/100))	
#	
# Smooth curves add to scatterplots of carat vs.\ price. The dsmall	
# dataset (1st) and the full dataset (2nd).	
qplot(carat, price, data = dsmall, geom = c("point", "smooth"))	
#	


