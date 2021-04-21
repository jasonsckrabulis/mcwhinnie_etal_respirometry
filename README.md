
## McWhinnie _et al_. - Temperature and mass scaling affect cutaneous and pulmonary respiratory performance in a diving frog

An open-source flow-through respirometry device to measure flow rate and percent oxygen.

---

### Authors and maintainers

Ryan B McWhinnie: rbmcwhin@gmail.com

Jason P Sckrabulis: jason.sckrabulis@gmail.com

Thomas R Raffel: raffel@oakland.edu

>Conceptualization: TRR, RBM, & JPS. Methodology: TRR, RBM, & JPS. Analysis: RBM, TRR, & JPS. Respirometer design: JPS. Respirometer construction: JPS & RBM. Writing – review & editing: RBM & TRR. Funding acquisition: TRR. Literature searching: RBM & TRR.

### Issues and suggestions

Please email jason.sckrabulis@gmail.com with any issues or suggestions for the respirometry device, or submit via the GitHub issues tab for this [repository](https://github.com/jasonsckrabulis/mcwhinnie_etal_respirometry/issues).
For questions concerning the manuscript, please email the corresponding author at raffel@oakland.edu.

### Change log

* Aug 12, 2019: First full commit

### Citation

Please cite work as:  
>TBD

---

### Summary

Our goal for this project was to develop a low-cost alternative to conventional commerical respirometry apparatuses in order to conduct temperature experiments with true replication of temperatures, which requires measuring many animals at the same time. As a result, we developed a flow-through respirometry device able to measure flow rate (SCCM) and percent oxygen (volumetric) simultaneously. Our device is based on the Arduino platform and uses components found at a majority of electronics suppliers (i.e., [Mouser](https://mouser.com) and [Adafruit](https://adafruit.com)). Each device is under $200 (USD) with a footprint smaller than a mousepad at the time of purchase (2018). During our experiments, we were able to describe multiple aspects of respiratory activity in the diving frog _Xenopus laevis_. See full manuscript at the above citation for this analysis.

---

### Repository contents

* README.md  
* Bill of Materials.csv  
   Parts list, excluding an enclosure, O2 modification, general supplies & equipment, and microSD card  
* data (will be uploaded upon acceptance)  
   Folder of experimental data as .csv and accompanying .txt files used in data analysis for manuscript  
   * Example Respirometry Measurement.csv  
   * McWhinnie et al. 2019 Breath Bout Data.csv  
   * McWhinnie et al. 2019 Master Data.csv  
* RespirometryDevice.txt  
   Arduino program code, provided as a .txt file for editing and viewing in any text editor.  
* imgs  
   Folder of images used in README.md

---

### Respirometer development

For our respirometry devices to be viable, low-cost alternatives to commerical products, we opted to develop the device on the [Arduino platform](https://arduino.cc). Arduino is an open-source microcontroller platform designed to be accessible to new users with little programming and/or electronics expertise. Since its release, a mass accumulation of documentation, tutorials, and code examples exists on the internet. Due to its open-source nature, other companies have taken the Arduino platform and tailored it to specific needs (e.g., Adafruit). Adafruit's Pro Trinket product line further reduced costs by reducing the number of available analog and digitial I/O pins, footprint. For our fast processing and 5V sensor requirements, we utilized the Adafruit Pro Trinket 5V 16MHz microcontroller (Fig. 1A, #1) for our devices. In our case, we used right-angle headers for the FTDI pins of the Pro Trinket to better fit our enclosure and allow for flow rate calibration when connected to a computer.

We used the Honeywell Zephyr<sup>TM</sup> analog airflow rate sensor (Fig. 1A, #5; Fig. 1C, #9) to measure flow in standard cubic centimeters per minute (SCCM). This analog version of the sensor directly measures resistance change of temperature-sensitive resistors influenced by the flow rate. This line of sensors was designed for medical and industrial use and has a fast response time, making it ideal to capture small changes in flow produced by the lung movements of air in small frogs and other amphibians. The Zephyr<sup>TM</sup> line also has a linear output and customizable packages for easier integration by the end user's application.

We used the Seeed Studio Grove oxygen sensor package (Fig. 1A, #4) designed for Arduino applications. This package uses a replacable MEQ-O2 gas sensor, designed for use in enclosed areas (i.e., mines). Oxygen was reported as a volumetric percentage of air by measuring current change based on the electrochemical reaction of the gas on a heated electrode. We modified the sensor (Fig. 1C, #8) for use in a flow-through system by modifying and sealing a plastic coin case and air tubing connectors. Within the coin case, we made a channel with cut nylon washers and hot glue such that only the supplied air for respiration was accessed by the sensor.

For experimental use, we added a microSD card (Fig. 1A, #7) and real-time clock modules (Fig. 1A, #6). This allowed for data collection throughout the entire respiration period (~90 minutes in our experiments). For ease of use, the device has an integrated power jack, which can by powered by an appropriate DC power supply adapter, or 9V battery power (with connector) (Fig. 1A, #2). The device supports up to 100 unique data files (microSD card capacity dependent), as well as be controlled via switch (Fig. 1A, #3), and indicator LEDs (Fig. 1A, #2) for status for further ease of use. Completed device photos are presented in Fig. 1B & C.

<img src="https://github.com/jasonsckrabulis/mcwhinnie_etal_respirometry/blob/master/imgs/schematic.png" width=60%>
Figure 1: Respirometry device schematic and photos. A) Schematic of Adafruit Pro Trinket microcontroller and electronic components. Wire colors are based on standard electronics coding. Numbers indicate components: (1) Pro Trinket, (2) Power jack and indicator LEDs, (3) input switch, (4) Seeed Grove oxygen sensor, (5) Zephyr™ flow sensor, (6) Real-time clock (RTC) module, and (7) microSD card module. (4) and (5) are depicted as generic connectors, but the right-most pin is “pin 1” of each module. Schematic generated in Fritzing (v0.9.3; https://www.fritzing.org) with Adafruit, Seeed Studio, and Sparkfun parts libraries. B) Front of a respirometry device, which has a clear cover to also allow visualization of LEDs inside the box during measurements. C) Back of a respirometry device, showing (8) oxygen sensor covered by a modified plastic coin holder that channels air over the sensor and (9) airflow sensor ports. 

#### Operation

The respirometry device was designed for ease of use. See Figure 2 for a pictoral representation of the following text, but see RespirometerDevice.txt for complete, commented operational code. Upon receiving power, the device checks for a valid microSD card, and enters _Standby_ until the switch is flipped. When the switch is flipped and the digital input is detected, the device creates and opens a new data log file and enters _Warm-up_, where voltage is supplied to the oxygen sensor for 20 minutes followed by 30ms for the flow rate sensor (manufacturer specifications). After _Warm-up_, the device enters _Collection_ and records the actual start time as tracked by the RTC. It is important to note that RTC time regularly drifts, and we recommend initializing RTC prior to every experimental block.  In _Collection_ the device measures voltage and current change of both sensors, calculates flow rate and oxygen percentage, and loads them into memory. When the user flips the switch again, the device records all data to the data file, closes it, and enters _Standby_. The device supports multiple experimental periods by continuing to enter and exit _Standby_ following measurements. We were able to collect and average of ~80 measurements per second, allowing us to measure small changes in flow rate by lung movement of small frogs and amphibians.

<img src="https://github.com/jasonsckrabulis/mcwhinnie_etal_respirometry/blob/master/imgs/operation.png" width=60%>
Figure 2: Outline of microcontroller-driven respirometry device operation programming.

#### Example

Measurements logged by our respirometry device for a single animal's measurement are provided in [data](https://github.com/jasonsckrabulis/mcwhinnie_etal_respirometry/tree/master/data). Once an individual's respiratory performance was measured, we quantified metabolism as four proxies: 1) cutaneous respiration, 2) pulmonary respiration, 3) total respiration, and 4) breath rate. For a detailed description of experimental methods, see the full manuscript. Our device was used to quantify only 2 & 4 though direct calculation of oxygen (2) and counting of individual breaths (4). All analyses and data manipulation were done in R (v3.5.1; https://www.r-project.org).

To quantify pulmonary respiration, we needed to establish a baseline level for flow rate and percent oxygen, as defined by the values for each of these parameters when frogs were not breathing. Diving frogs like _X. laevis_ typically have extended 'gap' periods with no breaths punctuated by distinct periods of breathing activity, which will be referred to from here on as 'breath bouts'. When plotted as a time series, these breath bouts are visually distinguishable from the gaps between breaths, making it possible to select representative baseline data between breath bouts and use it to establish a continuous running baseline through the entire time series. We used the `fhs` function from the `gatepoints` package to freehand select representative data for each baseline, excluding data more than 5 mL min−1 or 0.1% away from the visually apparent baseline for each flow or O2 dataset, respectively (Fig. 3). Once this was done, the `na.fill` function from the `zoo` package was used to fill 'NA's from the selected baseline dataset based on the surrounding data. To finalize baseline correction, a cubic smoothing spline was fit to each baseline dataset to generate a continuous baseline function (`smooth.spline` from the base package). The spline fit was then subtracted from the original (raw) dataset to generate a baseline-corrected  data series centered around zero for flow rate (e.g., Fig. 3B) and percent oxygen (e.g., Fig. 3D). Following baseline correction, breath bout volumes and total oxygen consumption were calculated by multiplying the change in flow rate or percent oxygen from the baseline against the time frame for each specific measurement (i.e., the integral of the curve). These values yield the volume of flow or percent oxygen for each reading with sums being added for both positive and negative values to determine respective values for the entire measurement. See full manuscript for actual calculations.

<img src="https://github.com/jasonsckrabulis/mcwhinnie_etal_respirometry/blob/master/imgs/example.png" width=60%>
Figure 3: Process of baseline-correcting time series data for oxygen percentage (A, B) and air flow rate (C, D) for a single representative breath bout. The baseline itself (red curve in panels A & C) was generated by fitting a smoothing spline to the selected baseline data, and this baseline was then subtracted from the raw data to generate a baseline-corrected dataset. The smoothing spline fit (red line), representing the baseline, is superimposed over the raw data (black lines) in panels A & B. Data selected to represent the 'baseline' (red lines) are superimposed over the raw data (black lines) in panels C & D. There is approximately a 3-5s delay between changes in flow rate and changes in oxygen percentage because of the time it takes the air from the frog to react with the oxygen sensor, whereas the change in air flow rate is instantaneously measured.
