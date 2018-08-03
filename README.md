# Oilspill_model

## Introduction

In this repository an oil spill particle dispersion model implemented in Julia, is described. 

 The model is based on a Lagrangian particle tracking algorithm with a second-order Runge-Kutta scheme. It uses ocean currents from the Hybrid Coordinate Ocean Model (HYCOM), and winds from the Weather Research and (WRF).

 The model considers eight oil components according to their density, and includes multiple types of oil decay: evaporation,
biodegradation, burning, and gathering.

 Finally, it allows simultaneous modeling of several oil spills at multiple locations.

## Modules 
 The model is based on six general modules as show in Fig. 1. 

![Figure 1](https://github.com/AndreaAnguiano/Oilspill_model-/blob/master/tools/juliamodel.png)
Fig 1. Main components and associated files of the oil spill model. 

### Read Data
In this module are the scripts that read the oceanic and atmospheric data.
In the OilSpillData.jl file the model calculates the quantities of surface and sub-surface oil, as well as the amount of evaporated oil according to the formulations on the Oil Budget Calculator [1].
If the user wants to run the model with his own data, modify the VectorFields.jl file is necessary.

### Pre-processing
In this module are the scripts that assign the number and type of particles that releases in each time step and day and start the release, it is based on the Oil Budget Calculator. 

### Post-processing
In this module are the scripts that calculate the statistics of the particles at the end of each simulation. The file modelStatistics.jl shows all the statistics available for the particles. It is composed by three main functions that calculates: 1) The type of degradation and the type of oil of each particle. 
2) The number of particles and the type of oil of these particles.
3) The number of particles located in a selected area by the user and the type of oil of these particles. 

### Visualization
In this module are the scripts that plot the results of statistics and the maps. 
