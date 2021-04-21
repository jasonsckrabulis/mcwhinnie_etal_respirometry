# Integral calculations for oxygen measurements for an entire experimental block for total oxygen consumption

####
# Make a vector of all filenames, full path names required to use output as loop
# Change initial file path to match G Drive location and run only the one needed for your analysis
# Each block can be filtered out as needed with pattern="_".

# Oxygen example (Files organized into folders for each experimental block, no additional filter needed)
filename <- list.files(path="PATH_TO_FOLDER", pattern="Laevis", full.names=TRUE)

# Confirm it pulled files out
filename

#Breath bout example (Files also organized with day in filename: "NegDay", "ZeroDay", "OneDay", "FourDay", & "EightDay")
filename <- list.files(path="PATH_TO_FOLDER", pattern="ZeroDay", full.names=TRUE)

# Confirms it pulled files out
filename

# Function to calculate all integrals
# Arguments:
# filename: path to the file of interest
# type: type="oxygen" for output for overall O2 Percent change, type="breaths" for output for individual breaths O2 Percent and flow rate
RespIntegrals <- function(filename, type){
	
	# Determine if type = oxygen calculation
	if(type == "oxygen"){
		
		# Read csv and subset first datapoint out (it has interval=0)
		dat <- read.csv(file=filename, header=TRUE)
		dat <- subset(dat, interval!=0)
		
		# Get total time of respiration
		totalTimeSec <- max(dat$Seconds)
	
		# Subset negative baseline and raw values
		negBase <- subset(dat, correctedBaseO2<=0)
		negRaw <- subset(dat, correctedRawO2<=0)
	
		# Subset positive baseline and raw values
		posBase <- subset(dat, correctedBaseO2>0)
		posRaw <- subset(dat, correctedRawO2>0)
	
		# Calculate negative integral
		negBaseInt <- sum(negBase$correctedBaseO2*negBase$interval)
		negRawInt <- sum(negRaw$correctedRawO2*negRaw$interval)
		negTotalO2 <- (abs(abs(negRawInt) - abs(negBaseInt)))/100
	
		# Calculate positive integral
		posBaseInt <- sum(posBase$correctedBaseO2*posBase$interval)
		posRawInt <- sum(posRaw$correctedRawO2*posRaw$interval)
		posTotalO2 <- abs(abs(posRawInt) - abs(posBaseInt))
	
		# Check baseline approximates 0
		baseCheck <- abs(abs(negBaseInt) - abs(posBaseInt))
	
		# Output integral calculations
		output <- c(totalTimeSec, negBaseInt, posBaseInt, baseCheck, negRawInt, negTotalO2)
		output
	
	# Otherwise breath calculations
	} else if (type == "breaths"){
		
		# Read csv and subset first datapoint out (it has interval=0)
		dat <-read.csv(file=filename, header=TRUE)
		dat <- subset(dat, interval!=0)
		
		# Get total time of respiration
		totalTimeSec <- max(dat$Seconds)
		
		# Get start time in milliseconds
		startMillis <- min(dat$Millis)
	
		#Get end time in milliseconds
		endMillis <- max(dat$Millis)
	
		#Percent oxygen calculations
		# Subset negative baseline and raw values
		negBaseO2 <- subset(dat, corBaseO2<=0)
		negRawO2 <- subset(dat, corRawO2<=0)
	
		# Subset positive baseline and raw values
		posBaseO2 <- subset(dat, corBaseO2>0)
		posRawO2 <- subset(dat, corRawO2>0)
	
		#Calculate negative integral
		negBaseIntO2 <- sum(negBaseO2$corBaseO2*negBaseO2$interval)
		negRawIntO2 <- sum(negRawO2$corRawO2*negRawO2$interval)
		negTotalO2 <- (abs(abs(negRawIntO2) - abs(negBaseIntO2)))/100
	
		# Calculate positive integral
		posBaseIntO2 <- sum(posBaseO2$corBaseO2*posBaseO2$interval)
		posRawIntO2 <- sum(posRawO2$corRawO2*posRawO2$interval)
		posTotalO2 <- abs(abs(posRawIntO2) - abs(posBaseIntO2))
	
		# Check baseline approximtes 0
		baseCheckO2 <- abs(abs(negBaseIntO2) - abs(posBaseIntO2))
	
		#Flow rate calculations
		# Subset negative baseline and raw values
		negBaseFlow <- subset(dat, corBaseFlow<=0)
		negRawFlow <- subset(dat, corRawFlow<=0)
		
		#subset positive baseline and raw
		posBaseFlow<-subset(dat,corBaseFlow>0)
		posRawFlow<-subset(dat,corRawFlow>0)
		
		#negative integral
		negBaseIntFlow<-sum(negBaseFlow$corBaseFlow*negBaseFlow$interval)
		negRawIntFlow<-sum(negRawFlow$corRawFlow*negRawFlow$interval)
		negTotalFlow<-abs(abs(negRawIntFlow)-abs(negBaseIntFlow))
	
		#positive integral
		posBaseIntFlow<-sum(posBaseFlow$corBaseFlow*posBaseFlow$interval)
		posRawIntFlow<-sum(posRawFlow$corRawFlow*posRawFlow$interval)
		posTotalFlow<-abs(abs(posRawIntFlow)-abs(posBaseIntFlow))
	
		#baseline check
		baseCheckFlow<-abs(abs(negBaseIntFlow)-abs(posBaseIntFlow))
		
		#test output
		outputO2<-c(totalTimeSec,negBaseIntO2,posBaseIntO2,baseCheckO2,negRawIntO2,posRawIntO2,negTotalO2,posTotalO2)
		outputFlow<-c(totalTimeSec,startMillis,endMillis,negBaseIntFlow,posBaseIntFlow,baseCheckFlow,negRawIntFlow,posRawIntFlow,negTotalFlow,posTotalFlow)
		#output2test<-rbind(outputO2,outputFlow)
		#output2test
		output2<-c(totalTimeSec,startMillis,endMillis,negBaseIntO2,posBaseIntO2,baseCheckO2,negRawIntO2,posRawIntO2,negTotalO2,
			negBaseIntFlow,posBaseIntFlow,baseCheckFlow,negRawIntFlow,posRawIntFlow,negTotalFlow,posTotalFlow)
		output2
	}
}

#vector for header names
###########################
#only run the lines for the analysis in question (header lengths are different for each)
###########################
#_____________________________
#this for overall oxygen
header<-c("filename","totalTimeSec","negBaseInt","posBaseInt","baseCheck","negRawInt","negTotal")
df<-data.frame(matrix(ncol=6,nrow=0))

#_____________________________
#this for individual breaths
header<-c("filename","totalTime","negBaseIntO2","posBaseIntO2","baseCheckO2","negRawIntO2","posRawIntO2","negTotalO2",
	"negBaseIntFlow","posBaseIntFlow","baseCheckFlow","negRawIntFlow","posRawIntFlow","negTotalFlow","posTotalFlow")
df<-data.frame(matrix(ncol=14,nrow=0))

#loop to read each csv and calculate integrals
for(f in filename){
###########################
	#be sure to change type="__" below to what you need; "oxygen" or "breaths"
###########################
	int<-RespIntegrals(filename=f,type="oxygen")

	#construct data frame
	df<-rbind(df,int)
}

#system makes alarm noise when done processing loop
alarm()

#add file names to data frame
newdf<-cbind(filename,df)
colnames(newdf)<-header

#Detrended oxygen
#################################################################################
#NEED TO RENAME EACH FILE FOR EACH BLOCK
write.csv(newdf,
"FILENAME")
#################################################################################

#individual breath bout
#################################################################################
#NEED TO RENAME EACH FILE FOR EACH BLOCK
write.csv(newdf,
"FILENAME")
#################################################################################
