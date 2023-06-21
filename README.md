# VisualFlickerVoltageImaging
This repository contains scripts that plot the figure 1B and 1C for manuscript ""Brain rhythms control microglial response and cytokine expression via NFκB signaling".

## General information: 
### animals
6 EMX1-Cre mice were used for the experiments. These mice expressed JEDI-1P-Kv and mCherry. 
All mice were water restricted and head-fixed during the imaging. 

### imaging
Imaging was acquired at 200Hz. Each imaging trial is 20.48s long. 

### flicker experiments: 
LED: ~400 lux at at the head of the animals. 50% duty cycle for both 20 Hz and 40 Hz. The first half of the trial is baseline, and the LED was on in the second half of the trial. 
10 trials/animal for 20 Hz flicker. 
10 trials/animal for 40 Hz flicker.


## Repository contains:
### scripts: 
  scripts used to generate the plots -- spatial maps of power at 20 or 40 Hz, peristimulus response of V1, PSA of response at V1, mean response at V1. 
### data: 
  processed data for generating the plots Figure 1B, 1C, and 1S. Data are in .mat format. 
### masks: 
  file for masking the spatial maps. 

