# Total pulmonary oxygen calculations

####
# Libraries
library(gatepoints)
library(zoo)

####
# Select individual frog's raw measurement
mydata <- read.csv(file.choose(),header=TRUE)

# Subset data to not include NAs
SelectData <- subset(mydata[,c(3,9)], Millis!="NA")

####
# Make large plot device and plot O2 data
dev.new(width=16, height=12)
plot(SelectData$Millis, SelectData$O2Percent, cex=0.5, ylim=c(mean(SelectData$O2Percent)-1, mean(SelectData$O2Percent)+0.5), main="Raw Data")

# O2 baseline selection: Only select the baseline, do not include the positive and negative peaks for the breath itself
# The recovery period for O2 measurements can be long, be mindful of the long right tail of the breath
# Only include +- 3 steps from the apparent average (equal to the variation in the sensor)
# This selection will take a long time to run
selectedPoints <- fhs(SelectData, mark = TRUE)

# Assign selected points as a vector
selectedPoints <- as.numeric(selectedPoints)

# Assign SubsetMillis as a vector
SubsetMillis <- numeric(length(mydata$Millis))
# Replace all zeros in data to NA
SubsetMillis[SubsetMillis==0] <- NA

# Assign SubsetO2 as a vector
SubsetO2 <- numeric(length(mydata$Millis))
# Replace all zeros in data to NA
SubsetO2[SubsetO2==0] <- NA

# Insert selected data into these vectors and create new data frame
for(i in 1:length(selectedPoints)){
	  SubsetMillis[selectedPoints[i]] <- mydata$Millis[selectedPoints[i]]
	  SubsetO2[selectedPoints[i]] <- mydata$O2Percent[selectedPoints[i]]
}

# Subsetted data set as data frame
SubsetData <- cbind(SubsetMillis,SubsetO2)

####
# EXIT OUT OF CURRENT PLOT WINDOW#

# New plot with 2 vertical panels
par(mfrow=c(2,1))

# Plot selected data, if you do not see anything plotted it is likely out of the y scale
plot(SubsetMillis, SubsetO2, ylim=c(16,20), main="Subset Data")

# Fill unselected areas with NAs
interpolateO2 <- na.fill(SubsetData[,2], c(NA,"extend", NA))
interpolateMillis <- na.fill(SubsetData[,1], c(NA,"extend", NA))
interdata <- cbind(SubsetData, interpolateMillis, interpolateO2)

# Plot new data, if you do not see anything plotted it is likely out of the y scale
plot(interpolateMillis, interpolateO2, ylim=c(16,20), cex=0.25, main="Interpolate")

# Remove NAs that appear on ends of dataset
interdata <- subset(interdata, interpolateMillis!="NA")

# Fit a smoothing splne to baseline
sm <- smooth.spline(interdata[,3], interdata[,4], spar=1)

# Plot new data, if you do not see anything plotted it is likely out of the y scale
lines(predict(sm), ylim=c(16,20), col="green")

# detrendedBaseO2 = raw data - baseline
detrendedBaseO2 <- interdata[,4] - sm$y
detrendedBaseO2 <- as.vector(detrendedBaseO2)

####
# EXIT OUT OF CURRENT PLOT WINDOW

# Plot data and spline to ensure congruency
plot(mydata$Millis, mydata$O2Percent, type="l", main="Raw Data")
lines(sm$x, sm$y, type="l", col="red")

# Find the first element of sm$x and match to selection
SubsetRaw <- subset(SelectData, Millis>=SelectData$Millis[match(sm$x[1], SelectData$Millis)])

# Baseline correct the raw data (raw - spline)
correctedRawO2 <- SubsetRaw$O2Percent - sm$y

# Note: if the above gives 'objects have different lengths' error: 
# Run code below (L92 & L93) to cut off datapoints that are at the end of the data, they were not selected with free-hand select due to being outside selection range but still remain in the dataset. sm$y is not extended to those points
SubsetRaw2 <- SubsetRaw$O2Percent[-((length(sm$y)+1):length(SubsetRaw$O2Percent))]
correctedRawO2 <- SubsetRaw2 - sm$y


# Plot of baseline corrected data
plot(correctedRawO2, type="l", main="Corrected Raw")

# Plot data and correction
par(mfrow=c(2,1))
plot(mydata$Millis, mydata$O2Percent, type="l", main="Raw Data")
lines(sm$x, sm$y, type="l", col="red")
plot(sm$x, correctedRawO2, type="l", main="Baseline Corrected")
lines(sm$x, detrendedBaseO2, type="l", col="red")

# Calculate and insert seconds NOT milliseconds
dtBaseO2 <- as.data.frame(cbind(Seconds=sm$x/1000, correctedBaseO2=detrendedBaseO2, correctedRawO2=correctedRawO2))
dtBaseO2 <- subset(dtBaseO2, Seconds!="NA")

# Start seconds at zero
dtBaseO2$Seconds <- dtBaseO2$Seconds - min(dtBaseO2$Seconds)

# Calculate interval between readings starting at second time point
interval <- numeric(length(dtBaseO2$Seconds))
for(i in 2:length(dtBaseO2$Seconds)){
	interval[i] <- dtBaseO2$Seconds[i] - dtBaseO2$Seconds[i-1]
}

# Make a new data frame with seconds, correctedRawO2, correctedBaseO2, and interval
dtBaseO2 <- as.data.frame(cbind(dtBaseO2, interval=interval))

####
# Write data frame to a .csv with full filename and path as chosen by user
write.csv(dtBaseO2, "FILENAME")
