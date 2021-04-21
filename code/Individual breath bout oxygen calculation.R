# Breath bout oxygen calculations

####
# Libraries
library(gatepoints)
library(zoo)

####
# Select individual frog's raw measurement dataset
mydata <- read.csv(file.choose(), header=TRUE)

# Subset FlowRate data to not include NA
SelectFlow <- subset(mydata[,c(3,6)], Millis!="NA")
# subset FlowRate data to not include NA
SelectO2 <- subset(mydata[,c(3,9)], Millis!="NA")

####
# Plotting both O2 & Flow rate to determine which 3 time sections are going to be used

# Make a LARGE custom plot window for O2 and flow rate graphs
par(mfrow=c(2,1), dev.new(width=29,height=18))

# Plot raw O2 to help determine breaths
plot(SelectO2$Millis, SelectO2$O2Percent, cex=0.25, ylim=c(mean(SelectO2$O2Percent)-1, mean(SelectO2$O2Percent)+0.5), main="Raw O2 Percent")
plot(SelectFlow$Millis, SelectFlow$FlowRate, type="l", main="Raw Flow Rate", ylim=c(-100,300))

####
# Change the timeframe explored during respiration measurement, this needs to be changed for each individual breath bout period examined
xlimit <- c(6.67e6,6.6905e6)

# Plot individual breath bout period, choose selection areas that include both the O2 & flow rate changes
plot(SelectO2$Millis, SelectO2$O2Percent, type="l", xlim=xlimit)
plot(SelectFlow$Millis, SelectFlow$FlowRate, type="l", xlim=xlimit, ylim=c(mean(SelectFlow$FlowRate)-150, mean(SelectFlow$FlowRate)+150))

# O2 baseline selection: Only select the baseline, do not include the positive and negative peaks for the breath itself
# The recovery period for O2 measurements can be long, be mindful of the long right tail of the breath
# Be sure to select baseline that includes the time period of the flow rate changes (from investigation plots above)
# Only include +- 3 steps from the apparent average (equal to the variation in the sensor)
dev.new(width=29, height=18)
plot(SelectO2$Millis, SelectO2$O2Percent, type="l", xlim=xlimit)
selectedPointsO2 <- fhs(SelectO2, mark=TRUE)
selectedPointsO2 <- as.numeric(selectedPointsO2)

# Flow rate baseline selection: Only select the baselinedo not include positive and negative peaks for breath itself
dev.new(width=29, height=18)
plot(SelectFlow$Millis, SelectFlow$FlowRate, type="l", xlim=xlimit, ylim=c(mean(SelectFlow$FlowRate)-200, mean(SelectFlow$FlowRate)+200))
selectedPointsFlow <- fhs(SelectFlow, mark = TRUE)
selectedPointsFlow <- as.numeric(selectedPointsFlow)

# Assign milliseconds as vectors for both O2 and flow rate
SubsetMillisO2 <- numeric(length(mydata$Millis))
SubsetMillisFlow <- numeric(length(mydata$Millis))

# Replace all zeros in data to NA
SubsetMillisO2[SubsetMillisO2==0] <- NA
SubsetMillisFlow[SubsetMillisFlow==0] <- NA

# Assign SubsetFlow as a vector
SubsetO2 <- numeric(length(mydata$Millis))
SubsetFlow <- numeric(length(mydata$Millis))

# Replace all zeros in data to NA
SubsetO2[SubsetO2==0] <- NA
SubsetFlow[SubsetFlow==0] <- NA

# Loops to insert selected data from above into vectors
for(i in 1:length(selectedPointsO2)){
	  SubsetMillisO2[selectedPointsO2[i]] <- mydata$Millis[selectedPointsO2[i]]
	  SubsetO2[selectedPointsO2[i]] <- mydata$O2Percent[selectedPointsO2[i]]
}

for(i in 1:length(selectedPointsFlow)){
	  SubsetMillisFlow[selectedPointsFlow[i]] <- mydata$Millis[selectedPointsFlow[i]]
	  SubsetFlow[selectedPointsFlow[i]] <- mydata$FlowRate[selectedPointsFlow[i]]
}

# Create data frame of data
SubsetDataBreath <- cbind(SubsetMillisO2, SubsetO2, SubsetMillisFlow, SubsetFlow)

####
# EXIT OUT OF CURRENT PLOT WINDOW

####
# Plot selected data, if you do not see anything plotted it is likely because FLOW RATE out of the y scale
par(mfrow=c(2,1), dev.new(width=29,height=18))
plot(SubsetMillisO2, SubsetO2,ylim=c(10,30), main="Subset O2")
plot(SubsetMillisFlow, SubsetFlow, ylim=c(50,350), main="Subset Flow")

# Fill unselected areas with NAs
interpolateMillisO2 <- na.fill(SubsetDataBreath[,1], c(NA,"extend",NA))
interpolateO2 <- na.fill(SubsetDataBreath[,2], c(NA,"extend",NA))
interpolateMillisFlow <- na.fill(SubsetDataBreath[,3], c(NA,"extend", NA))
interpolateFlow <- na.fill(SubsetDataBreath[,4], c(NA,"extend", NA))

# Bind new variables with data frame
interdataBreath <- cbind(SubsetDataBreath, interpolateMillisO2, interpolateO2, interpolateMillisFlow, interpolateFlow)

# Plot graph, will have to adjust flow rate ylim to fit proper bounds for each frog, if you do not see anything plotted, likely because out of the y scale
plot(interpolateMillisO2, interpolateO2, ylim=c(10,30), cex=0.25, type="l", main="Interpolated O2")
plot(interpolateMillisFlow, interpolateFlow, ylim=c(130,210), cex=0.25, type="l", main="Interpolated Flow")

# Remove NAs that appear on ends of dataset for O2 and flow separately
interdataO2 <- subset(interdataBreath, interpolateMillisO2!="NA")
length(interdataO2[,6])
interdataFlow <- subset(interdataBreath, interpolateMillisFlow!="NA")
length(interdataFlow[,8])

# Fit a smoothing spline to the baseline data
smO2 <- smooth.spline(interdataO2[,5], interdataO2[,6], spar=1)
smFlow <- smooth.spline(interdataFlow[,7], interdataFlow[,8], spar=1)

# Plot graph, will have to adjust flow rate ylim to fit proper bounds for each frog, if you do not see anything plotted, likely because out of the y scale
plot(interpolateMillisO2, interpolateO2, ylim=c(10,30), cex=0.25, type="l", main="Interpolated O2")
lines(predict(smO2), ylim=c(16,20), col="green")
plot(interpolateMillisFlow, interpolateFlow, ylim=c(30,300), cex=0.25, type="l", main="Interpolated Flow")
lines(predict(smFlow), ylim=c(130,210), col="green")

# Use the spline fit of the baseline to detrend O2 and flow rate and make into a data frame
# detrendedBase = raw O2 - baseline
detrendedBaseO2 <- interdataO2[,6] - smO2$y
detrendedBaseO2 <- as.vector(detrendedBaseO2)
dtBaseO2 <- as.data.frame(cbind(Millis=interdataO2[,5], baselineO2=detrendedBaseO2))

# detrendedBase = raw Flow - baseline
detrendedBaseFlow <- interdataFlow[,8] - smFlow$y
detrendedBaseFlow <- as.vector(detrendedBaseFlow)
dtBaseFlow <- as.data.frame(cbind(Millis=interdataFlow[,7], baselineFlow=detrendedBaseFlow))

####
# Double check the lines() match the data

# Plot O2 and flow to double check congruency between the two
plot(mydata$Millis, mydata$O2Percent, type="l", xlim=xlimit)
lines(smO2$x, smO2$y, type="l", col="green")
plot(mydata$Millis, mydata$FlowRate, type="l", xlim=xlimit, ylim=c(mean(SelectFlow$FlowRate)-150, mean(SelectFlow$FlowRate)+350))
lines(smFlow$x, smFlow$y, type="l", col="green")

####
# The lengths of O2 and flow rate will be different and the data need to be matched up

#Function for trimming
RawData <- as.data.frame(cbind(Millis=mydata[,3], RawO2=mydata[,9], RawFlow=mydata[,6]))
RawData <- subset(RawData, RawData$Millis!="NA")

#arguments:
#data: data=entire dataset (ex: data = TrimData)
TrimBreath <- function(data){

	# Determine which selection has the higher STARTING Millis value
	if (smO2$x[1] > smFlow$x[1]){
		
		# Match the first element in smO2$x with full data and deselect everything lower than it
		data2 <- subset(data, Millis>=data$Millis[match(smO2$x[1],data$Millis)])
		
		# Determine which selection has the higher ENDING Millis value
		if (smO2$x[length(smO2$x)] > smFlow$x[length(smFlow$x)]){
			trimmed <- subset(data2, Millis<=data2$Millis[match(smFlow$x[length(smFlow$x)], data2$Millis)])
		} else if (smO2$x[length(smO2$x)] < smFlow$x[length(smFlow$x)]){
			trimmed <- subset(data2, Millis<=data2$Millis[match(smO2$x[length(smO2$x)], data2$Millis)])
		} else if (smO2$x[length(smO2$x)] == smFlow$x[length(smFlow$x)]){
			trimmed <- data
		}
	} else if (smO2$x[1] < smFlow$x[1]){
		
		# Match first element in smFlow$x with full data and subset out everything lower than it
		data2 <- subset(data, Millis>=data$Millis[match(smFlow$x[1], data$Millis)])
		
		# Determine which selection has the higher ENDING Millis value
		if (smO2$x[length(smO2$x)] > smFlow$x[length(smFlow$x)]){
			trimmed <- subset(data2, Millis<=data2$Millis[match(smFlow$x[length(smFlow$x)], data2$Millis)])
		} else if (smO2$x[length(smO2$x)] < smFlow$x[length(smFlow$x)]){
			trimmed <- subset(data2, Millis<=data2$Millis[match(smO2$x[length(smO2$x)], data2$Millis)])
		} else if (smO2$x[length(smO2$x)] == smFlow$x[length(smFlow$x)]){
			trimmed <- data
		}
	} else if (smO2$x[1] == smFlow$x[1]){
		data2 <- data
		
		# Determine which selection has the higher ENDING Millis value
		if (smO2$x[length(smO2$x)] > smFlow$x[length(smFlow$x)]){
			trimmed <- subset(data2, Millis<=data2$Millis[match(smFlow$x[length(smFlow$x)], data2$Millis)])
		} else if (smO2$x[length(smO2$x)] < smFlow$x[length(smFlow$x)]){
			trimmed <- subset(data2, Millis<=data2$Millis[match(smO2$x[length(smO2$x)], data2$Millis)])
		} else if (smO2$x[length(smO2$x)] == smFlow$x[length(smFlow$x)]){
			trimmed <- data2
		}
	}
	# Make smO2, smFlow into tables, then trim those data
	o2 <- cbind(smO2$x,smO2$y)
	o2 <- subset(o2, o2[,1]>=trimmed$Millis[1])
	o2 <- subset(o2, o2[,1]<=trimmed$Millis[length(trimmed$Millis)])
	
	flow <- cbind(smFlow$x,smFlow$y)
	flow <- subset(flow, flow[,1]>=trimmed$Millis[1])
	flow <- subset(flow, flow[,1]<=trimmed$Millis[length(trimmed$Millis)])
	
	trimmed <- as.data.frame(cbind(trimmed, smO2=o2[,2], smFlow=flow[,2]))
}

# Run the function on the raw data
TrimData <- TrimBreath(data=RawData)

# correctedRaw = trimmed raw - smoothing spline
correctedRawO2 <- TrimData$RawO2 - TrimData$smO2
correctedRawFlow <- TrimData$RawFlow - TrimData$smFlow

# Plot corrected raw O2 and raw Flow
plot(TrimData$Millis, correctedRawO2, type="l", main="Corrected Raw O2")
lines(interdataO2[,5], detrendedBaseO2, col="green")
plot(TrimData$Millis, correctedRawFlow, type="l", main="Corrected Raw Flow")
lines(interdataFlow[,7], detrendedBaseFlow, col="green")

# Subset detrendedBase based on TrimData values
dtBaseO2 <- subset(dtBaseO2, Millis>=TrimData$Millis[1])
dtBaseO2 <- subset(dtBaseO2, Millis<=TrimData$Millis[length(TrimData$Millis)])
dtBaseFlow <- subset(dtBaseFlow, Millis>=TrimData$Millis[1])
dtBaseFlow <- subset(dtBaseFlow, Millis<=TrimData$Millis[length(TrimData$Millis)])

# Calculate and insert seconds NOT milliseconds
dtBase <- as.data.frame(cbind(Seconds=TrimData$Millis/1000, Millis=TrimData$Millis, corBaseO2=dtBaseO2$baselineO2, corRawO2=correctedRawO2, corBaseFlow=dtBaseFlow$baselineFlow, corRawFlow=correctedRawFlow))
dtBase <- subset(dtBase, Seconds!="NA")

# Start seconds at zero
dtBase$Seconds <- dtBase$Seconds - min(dtBase$Seconds)

# Calculate interval between readings starting from second time point
interval <- numeric(length(dtBase$Seconds))
for(i in 2:length(dtBase$Seconds)){
	interval[i] <- dtBase$Seconds[i] - dtBase$Seconds[i-1]
}

# Make a new data frame with seconds, correctedRawO2, correctedBaseO2, and interval
dtBreath <- as.data.frame(cbind(dtBase, interval=interval))

# Shows xlimits to remind where individual breath is in raw data
xlimit

# Plot raw data to record seconds in file name
plot(mydata$Millis/1000,mydata$O2Percent,type="l")

####
# Write data frame to a .csv with full filename and path as chosen by user
write.csv(dtBreath, "FILENAME")
