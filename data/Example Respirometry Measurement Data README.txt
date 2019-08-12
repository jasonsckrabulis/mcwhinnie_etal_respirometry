Example Respirometry Measurement Data README

Variables:

Date		Measurement start date, calculated by real-time clock module
ReadTime	Time of day of measurement start date, calculated by real-time clock module
Millis		Milliseconds since power was provided to device, for time series
FlowAnalog	Number of analog reads (0 to 1023) on the flow rate sensor pin
FlowVoltage	Calculated voltage based on FlowAnalog
FlowRate	Calculated flow rate in SCCM based on voltage
O2Analog	Number of analog reads (0 to 1023) on the oxygen sensor pin
O2Voltage	Calculated voltage based on O2Analog
O2Percent	Calculated oxygen percentage based on voltage