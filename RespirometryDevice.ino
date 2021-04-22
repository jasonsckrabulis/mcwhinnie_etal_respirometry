//McWhinnie et al. - Temperature and mass scaling affect cutaneous and pulmonary respiratory performance in a diving frog
//Respirometry device operational code
//___________________________

//Libraries

//SD card library (included in Arduino IDE)
//SD card library requires digital pins 10, 11, 12, 13
#include <SD.h>

//I2C communications library for the real-time clock module (RTC) (included in Arduino IDE)
#include <Wire.h>

//RTC library (uses Wire.h, from https://github.com/adafruit/RTClib)
//Set RTC clock via https://learn.adafruit.com/adafruit-pcf8523-real-time-clock/rtc-with-circuitpython?view=all#usage)
#include <RTClib.h>

//___________________________
//Variable Definitions

//Empty data logger file name
File logFile;

//RTC object
RTC_Millis rtc;

//Minimum time for applied voltage to flow sensor before readings are valid (30ms, per specifications)
const int warmupFlowTime = 30;

//Minimum time for applied voltage to O2 sensor before readings are valid (20min = 1200000ms = 300000ms * 4 breaks, per specifications)
const long warmupO2Time = 300000;

//Interval between readings (ms), can adjust based on experimental need
const int readingInterval = 0;

//Empty variables for analog readings
int flowAnalog;
int o2Analog;

//Empty variables for time (milliseconds)
unsigned long startTime = millis();	//Logger start time since power on
unsigned long readingTime;	//Time of each reading
unsigned long endTime;		//Logger stop time since power on

//Debouncing of switch variables, to track binary state change in switch circuit
int switchVal = 0;		//Store current button state
int switchOldVal = 0;	//Store previous button state
int switchState = 0;	//0 = 'Standby state', 1 = 'Collection state'

//___________________________
//I/O Pin Definitions

//Analog (for reference, not needed in code)

//O2 sensor read
//airO2Pin = A2;

//Flow sensor read
//airFlowPin =  A3;

//Real-time clock (I2C connection)
//serialDataPin = A4;
//serialClockPin = A5;

//Digital

//Switch input
int startSwitchPin = 5;

//Flow sensor voltage supply
int flowSupplyPin = 4;

//O2 sensor voltage supply
int o2SupplyPin = 3;

//LEDs
int indicatorLedPin = 8;
int powerLedPin = 6;

//SD detector pin
int SdPresencePin = 10;

//___________________________
//Setup and initialization
void setup(){
	//Start serial communication through at 115200 baud (bits/s)
	Serial.begin(115200);
	
	//Set LED pins to output and default state off
	pinMode(indicatorLedPin, OUTPUT);
	digitalWrite(indicatorLedPin, LOW);
	pinMode(powerLedPin, OUTPUT);
	digitalWrite(powerLedPin, LOW);
	
	//Set switch pin to input
	pinMode(startSwitchPin, INPUT);
	
	//Set sensor pins to input
	pinMode(A2, INPUT);
	pinMode(A3, INPUT);
	
	//Set sensor voltage supply pins to output
	pinMode(flowSupplyPin, OUTPUT);
	pinMode(o2SupplyPin, OUTPUT);
	
	//Initialize RTC based on current date and time of PC when code is uploaded to microcontroller
    rtc.begin(DateTime(F(__DATE__), F(__TIME__)));
	
	//Initialize SD card
	Serial.println("Initializing SD card...");
	pinMode(SdPresencePin, OUTPUT);
	
	//SD card detection
	if (!SD.begin(SdPresencePin)){
		Serial.println("No SD Card.");
		delay(100);
	} else {
		Serial.println("SD Card Ready.");
	}
	
	//Wait before starting main loop
	delay(150);
	
	Serial.println("Waiting for input...");
}

//Function to create new SD card file (up to 100 unique files)
void newFile(){
	
	//Create new data file
	char fileName[] = "logger00.csv";
	
	//Loop to create multiple new files
	for (uint8_t i = 0; i < 100; i++){
		fileName[6] = i/10 + '0';
		fileName[7] = i%10 + '0';
		
		//Open new file only if it doesn't exist
		if (!SD.exists(fileName)){
			logFile = SD.open(fileName, FILE_WRITE);
			break;
		}
	}
	//Check for logger file error
	if (!logFile){
		Serial.println("Could not create file");
	} else if (logFile){
		
		Serial.print("Logging to: ");
		Serial.println(fileName);
		
		//Write new header if file exists
		logFile.println("Date,ReadTime,Millis,FlowAnalog,FlowVoltage,FlowRate,O2Analog,O2Voltage,O2Percent");
		
	}
}

//Main loop
void loop(){
	//Read and store button input
	switchVal = digitalRead(startSwitchPin);
	
	//Check for a state transition in switch
	if ((switchVal == HIGH) && (switchOldVal == LOW)){
		
		//Change state
		switchState = 1 - switchState;
		
		//Create and open new data file
		newFile();
		
		//Enter 'Collection state'
		Serial.println("Logging initiated");
		
		//Wait for minimum warmup time to equilibrate the o2 sensor
		digitalWrite(o2SupplyPin, HIGH);
		digitalWrite(indicatorLedPin, HIGH);
		delay(warmupO2Time);
		Serial.println("15 minutes left");
		delay(warmupO2Time);
		Serial.println("10 minutes left");
		delay(warmupO2Time);
		Serial.println("5 minutes left");
		delay(warmupO2Time);
		//Wait for minimum warmup time to equilibrate the flow sensor
		digitalWrite(flowSupplyPin, HIGH);
		delay(warmupFlowTime);
		
		//Start Time (rtc reading)
		DateTime now = rtc.now();
		
		//Date
		logFile.print(now.month(), DEC);
		logFile.print('/');
		logFile.print(now.day(), DEC);
		logFile.print('/');
		logFile.print(now.year(), DEC);
		logFile.print(',');
		//Time
		logFile.print(now.hour(), DEC);
		logFile.print(':');
		logFile.print(now.minute(), DEC);
		logFile.print(':');
		logFile.print(now.second(), DEC);
		logFile.print(',');
		//Empty readings
		logFile.println(" , , , , , , ");
		
		delay(100);
		
	}
	if ((switchVal == LOW) && (switchOldVal == HIGH)){
		
		//Change state
		switchState = 1 - switchState;
		
		//End time (rtc reading)
		DateTime now = rtc.now();
		
		//Date
		logFile.print(now.month(), DEC);
		logFile.print('/');
		logFile.print(now.day(), DEC);
		logFile.print('/');
		logFile.print(now.year(), DEC);
		logFile.print(',');
		//Time
		logFile.print(now.hour(), DEC);
		logFile.print(':');
		logFile.print(now.minute(), DEC);
		logFile.print(':');
		logFile.print(now.second(), DEC);
		logFile.print(',');
		//Empty readings
		logFile.println(" , , , , , , ");
		
		//Close data file.
		logFile.close();
		
	}
	
	//switch value is old, store it for comparison
	switchOldVal = switchVal;
	
	if (switchState == 1){
		
		//Power LED solid
		digitalWrite(powerLedPin, HIGH);
		
		//Read voltage from sensors
		flowAnalog = analogRead(A3);
		o2Analog = analogRead(A2);
		readingTime = millis();
		
		Serial.print("Reading Time (ms)");
		Serial.print(readingTime);
		Serial.print("\t");
		
		Serial.print("Flow Analog Read: ");
		Serial.print(flowAnalog);
		Serial.print("\t");
		
		//Calculate flow voltage from reading [analog * sensor reference voltage]/1023
		float flowVolt = flowAnalog * 5.0;
		flowVolt /= 1023.0;
		
		Serial.print("Flow Voltage: ");
		Serial.print(flowVolt);
		Serial.print("\t");
		
		//Calculate air flow rate from voltage, per specifications
		float flowRate = (750 * ((flowVolt/5.0)-0.5))/0.4;

		Serial.print("Flow Rate: ");
		Serial.print(flowRate);
		Serial.print("\t");
		
		//Calculate o2 voltage from reading [analog * sensor reference voltage]/1023
		float o2Volt = o2Analog * 5.0;
		o2Volt /= 1023.0;
		
		Serial.print("O2 Analog Read: ");
		Serial.print(o2Analog);
		Serial.print("\t");
		
		Serial.print("O2 Voltage: ");
		Serial.print(o2Volt);
		Serial.print("\t");
		
		//Calculate o2 percentage from voltage, per specifications
		float o2Percent = ((o2Volt * 0.21)/2.0)*100;
		
		Serial.print("O2 Percent: ");
		Serial.print(o2Percent);
		Serial.println("%");
		
		//Write to sd
		//Empty Date and ReadTime cells
		logFile.print(" , ,");
		//Millis
		logFile.print(readingTime);
		logFile.print(',');
		//Flow
		//Analog
		logFile.print(flowAnalog);
		logFile.print(',');
		//Voltage
		logFile.print(flowVolt);
		logFile.print(',');
		//Flow
		logFile.print(flowRate);
		logFile.print(',');
		//O2
		//Analog
		logFile.print(o2Analog);
		logFile.print(',');
		//Voltage
		logFile.print(o2Volt);
		logFile.print(',');
		//Flow
		logFile.println(o2Percent);

		//Delay between readings
		delay(readingInterval);
		
	} else if (switchState ==0){
		//Enter 'Standby state'
		
		//Turn off power to sensors
		digitalWrite(flowSupplyPin, LOW);
		digitalWrite(o2SupplyPin, LOW);
		digitalWrite(indicatorLedPin, LOW);
		
		//Blink every 1.5s until logger started
		digitalWrite(powerLedPin,LOW);
		delay(1500);
		digitalWrite(powerLedPin, HIGH);
		delay(1500);
		
	}
	
}

