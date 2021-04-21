# Total pulmonary oxygen calculations

####
# Libraries
library(gatepoints)
library(zoo)

# Select individual frog's raw measurement
mydata <- read.csv(file.choose(),header=TRUE)

# Subset data to not include NAs
SelectData <- subset(mydata[,c(3,9)], Millis!="NA")

# Make large plot device and plot O2 data
dev.new(width=16, height=12)
plot(SelectData$Millis, SelectData$O2Percent, cex=0.5, ylim=c(mean(SelectData$O2Percent)-1, mean(SelectData$O2Percent)+0.5), main="Raw Data")

#Enclose baseline in polygon -- ALLOW TO RUN, MAY TAKE A LITTLE
#Only select the three lines of variation. DO NOT INCLUDE BREATH POINTS.
selectedPoints <- fhs(SelectData, mark = TRUE)

#Assign selected points as a vector
selectedPoints<-as.numeric(selectedPoints)

#Assign SubsetMillis as a vector
SubsetMillis<-numeric(length(mydata$Millis))
#Replace all zeros in data to NA
SubsetMillis[SubsetMillis==0]<-NA

#Assign SubsetO2 as a vector
SubsetO2<-numeric(length(mydata$Millis))
#Replace all zeros in data to NA
SubsetO2[SubsetO2==0]<-NA

#insert selected and create new data frame
for(i in 1:length(selectedPoints)){
  SubsetMillis[selectedPoints[i]]<-mydata$Millis[selectedPoints[i]]
  SubsetO2[selectedPoints[i]]<-mydata$O2Percent[selectedPoints[i]]
  }

#Subsetted dataset
SubsetData<-cbind(SubsetMillis,SubsetO2)

#__________________________________________________________________________________
#################################
#EXIT OUT OF CURRENT PLOT WINDOW#
#################################

#new plot with 2 vertical panels
par(mfrow=c(2,1))

#plot selected data
#if you do not see anything plotted, likely because out of the y scale
plot(SubsetMillis,SubsetO2,ylim=c(16,20),main="Subset Data")

#fill NAs based on other data
interpolateO2<-na.fill(SubsetData[,2],c(NA,"extend", NA))
interpolateMillis<-na.fill(SubsetData[,1],c(NA,"extend", NA))
interdata<-cbind(SubsetData,interpolateMillis,interpolateO2)

#plot graph - will have to adjust ylim to fit proper bounds for each frog
#if you do not see anything plotted, likely because out of the y scale
plot(interpolateMillis,interpolateO2,ylim=c(16,20),cex=0.25,main="Interpolate")

#remove NAs that appear on ends of dataset
interdata<-subset(interdata,interpolateMillis!="NA")

#baseline correction
sm<-smooth.spline(interdata[,3],interdata[,4],spar=1)

#plot graph - WILL HAVE TO ADJUST YLIM BOUNDS FOR O2 DEPENDING ON EACH FROG
#if you do not see anything plotted, likely because out of the y scale
lines(predict(sm),ylim=c(16,20),col="green")

#detrendedBaseO2 = raw data - baseline
detrendedBaseO2<-interdata[,4] - sm$y
detrendedBaseO2<-as.vector(detrendedBaseO2)

#################################
#EXIT OUT OF CURRENT PLOT WINDOW#
#################################

#raw data
plot(mydata$Millis,mydata$O2Percent,type="l",main="Raw Data")
#adjustment
lines(sm$x,sm$y,type="l",col="red")

#what is the first Millis value in sm$x, where is that value in SelectData$Millis, subset raw data all Millis >= that value
SubsetRaw<-subset(SelectData,Millis>=SelectData$Millis[match(sm$x[1],SelectData$Millis)])

#baseline correct the raw data
correctedRawO2<-SubsetRaw$O2Percent-sm$y

#############################################################################################################################
#############################################################################################################################
#if the above gives 'objects have different lengths' error: 
#run code below to cut off datapoints that are at the end of the data,
#they were not selected with free-hand select due to being outside selection range
#but still remain in the dataset. sm$y is not extended to those points

SubsetRaw2<-SubsetRaw$O2Percent[-((length(sm$y)+1):length(SubsetRaw$O2Percent))]
correctedRawO2<-SubsetRaw2-sm$y
#############################################################################################################################
#############################################################################################################################

#plot of baseline corrected data
plot(correctedRawO2,type="l",main="Corrected Raw")

#plot data and correction
par(mfrow=c(2,1))
#raw data
plot(mydata$Millis,mydata$O2Percent,type="l",main="Raw Data")
#adjustment
lines(sm$x,sm$y,type="l",col="red")
#corrected data
plot(sm$x,correctedRawO2,type="l",main="Baseline Corrected")
#new baseline
lines(sm$x,detrendedBaseO2,type="l",col="red")

#calculate and insert seconds NOT milliseconds
dtBaseO2<-as.data.frame(cbind(Seconds=sm$x/1000,correctedBaseO2=detrendedBaseO2,correctedRawO2=correctedRawO2))
dtBaseO2<-subset(dtBaseO2,Seconds!="NA")
#start seconds at zero
dtBaseO2$Seconds<-dtBaseO2$Seconds-min(dtBaseO2$Seconds)

#calculates interval between readings starting at second time point
interval<-numeric(length(dtBaseO2$Seconds))
for(i in 2:length(dtBaseO2$Seconds)){
	interval[i]<-dtBaseO2$Seconds[i]-dtBaseO2$Seconds[i-1]
}

#make a new data frame with seconds, correctedRawO2, correctedBaseO2, and interval
dtBaseO2<-as.data.frame(cbind(dtBaseO2,interval=interval))

#################################################################################
#NEED TO RENAME EACH FILE FOR EACH FROG!i!i!i!i!i!i!i!i!i!i!i!i!i!i!i!i!i!i!i!i!i!
write.csv(dtBaseO2,
"G:/My Drive/Raffel Lab Documents/2018-2019 Project Folders/2018-2019 X. Laevis Respirometry/X laevis Respiration/Experimental Data/Pulmonary Data/Detrended Oxygen/Block Five/B5Laevis1DT.csv")
#################################################################################