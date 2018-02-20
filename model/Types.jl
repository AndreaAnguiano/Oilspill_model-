#constructor that contains all the values for the spill
using GeometricalPredicates
type OilSpillData
  dates::DateTime
  barrells::Array{Int64,1}
  inLandRecovery::Int64
  evaporate::Float64
  burned::Int64
  collected::Int64
  subsurfDispersants::Int64
  surfaceDispersants::Int64
  depths::Array
  barrellsPerParticle::Int64
  lat::Array{Float64,1}
  lon::Array{Float64,1}
end

type Decay
  burned::Array{Int64,1}
  collected::Array{Int64,1}
  evaporate::Array{Int64,1}
  biodeg::Array{Int64,1}
  byComponent::Array{Float64,1}
end
#constructor that initializes all these fields and validates the input
type modelConfig
  startDate::DateTime #Start date of the simulation in julian dates
  endDate::DateTime #End date of the simulation in julian dates
  depths::Array{Int64,1} #Array of depth to be used
  components::Array{Float64,2} #Array of components for each depth
  subSurfaceFraction::Array{Float64,1} #Array with the fraction of oil spilled at each subsurface depth
  decay::Decay
  timeStep::Int64 #The time step is in hours and should be exactly divided by 24
  initPartSize::Int64 #How big does we initialize the vector size of particles lats, lons, etc
  totComponents::Int64 #Total number of components
  windContrib::Float64 #The percentaje contribution of the wind into the model
  turbulentDiff::Float64 #Value of turbulent diffusion (When advecting particles)
  diffusion::Float64 #Variance of the diffusion (in degrees) when initializing particles
  model::String #Model used, HYCOM and ADCIRC
  spillType::String #Type of spill, oil and simple
  bbox::Array{Float64,1}
end

type vectorFields
  U::Array{Float64,3} #U variable for current time
  V::Array{Float64,3} #V variable for current time
  UT2::Array{Float64,3} #U variable for nex time
  VT2::Array{Float64,3} #V variable for nex time
  UW::Array{Float64,2} #U (wind) variable for current time
  VW::Array{Float64,2}#V (wind) variable for current time
  UWR::Array{Float64,2}
  VWR::Array{Float64,2}
  UWT2::Array{Float64,2} #U (wind) variable for nex time
  VWT2::Array{Float64,2}#V (wind) variable for nex time
  UWRT2::Array{Float64,2}
  VWRT2::Array{Float64,2}
  UWRT2minusUWRT::Array{Float64,2} #temporal variable that holds U(d_1) - U(d_0) Used for the interpolation
  VWRT2minusVWRT::Array{Float64,2}
  UD::Array{Float64,3} #This variable will alwats hold the currents of the current day
  VD::Array{Float64,3} #This variable will alwats hold the currents of the current day
  UDT2::Array{Float64,3} #This variable will alwats hold the currents of the next day
  VDT2::Array{Float64,3} #This variable will alwats hold the currents of the next day
  UDT2minusUDT::Array{Float64,3} #This variable will alwats hold the currents of the next day
  VDT2minusVDT::Array{Float64,3} #This variable will alwats hold the currents of the next day
  UWRD::Array{Float64,2} #This variable will always hold the winds of the previous closest timestep
  VWRD::Array{Float64,2}#This variable will always hold the winds of the previous closest timestep
  UWRDT2::Array{Float64,2}#This variable will always hold the winds of the next closest timestep
  VWRDT2::Array{Float64,2}#This variable will always hold the winds of the next closest timestep
  UWRDT2minusUWRDT::Array{Float64,2} #This variable will always has UDT2 - UD, is used to reduce computations in every iteration
  VWRDT2minusVWRDT::Array{Float64,2}#This variable will always has VDT2 - VD, is used to reduce computations in every iteration
  currDay::Int64 #Current day of the model
  currHour::Int64 #Current hour of the model
  lat::Array{Float64,1}
  lon::Array{Float64,1}
  latIdx::Array{Int64,1}
  lonIdx::Array{Int64,1}
  depths::Array{Float64,1} #Array of depths corresponding to U and V
  depthsMinMax::Array{Int64,1} #Array of indexes corresponding to the minumum and maximum depth of the particles
  depthsIndx::Array{Int64,2} #Array of indexes corresponding to closest indexes at each depth of the particles
  depthsRelativeIndx::Array{Int64,2} #Array of indexes corresponding to closest indexes at each depth of the particles for cutted U and V
  BBOX::Array{Float64,2}
end

type ParticlesByTimeStep
  particles::Float64
  partSub::Array{Float64,1}
  burned::Float64
  evaporated::Float64
  recovered::Float64
  lat::Array{Float64,1}
  lon::Array{Float64,1}
end


type Particle
  dates::Array{DateTime,1} #Indicates the dates for wich the particle has been alive in the model
  lat::Array{Float64,1} #Latitudes for each time step
  lon::Array{Float64,1} #Longitudes for each time step
  depths::Array{Float64,1} #Depths for each time step
  lifeTime::Int64 #The time in minutes that the particle has been alive
  component::Int64 #The component of the particle
  currTimeStep::Int64 #The current time step the particle is. It start at 1 and increase by one for each deltaT
  isAlive::Bool #Indicates if the particle is alive
  status::String #String that indicates the status of the particle. Each model shoud define it
end


type VectorFieldsADCIRC
  U::Array{Float64,2} #U variable for current time
  V::Array{Float64,2} #V variable for current time
  UT2::Array{Float64,2} #U variable for nex time
  VT2::Array{Float64,2} #V variable for nex time
  UW::Array{Float64,2} #U (wind) variable for current time
  VW::Array{Float64,2}#V (wind) variable for current time
  UWR::Array{Float64,2} #U (wind rotated) variable for current time
  VWR::Array{Float64,2} #V (wind rotated) variable for current time
  UWT2::Array{Float64,2} #U (wind) variable for nex time
  VWT2::Array{Float64,2}#V (wind) variable for nex time
  UWRT2::Array{Float64,2} #U (wind rotated) variable for next time
  VWRT2::Array{Float64,2} #V (wind rotated) variable for next time
  currDay::Int64 #Current day of the model
  currHour::Int64 #Current hour of the model
  lat::Array{Float64,1} #latitude vector of the currents and winds
  lon::Array{Float64,1} #longitude vector of the currents and winds
  depths::Array{Float64,1} #Array of depths corresponding to U and V
  depthsMinMax::Array{Int64,1} #Array of indexes corresponding to the minumum and maximum depth of the particles
  depthsIndx::Array{Int64,2} #Array of indexes corresponding to closest indexes at each depth of the particles
  atmFilePrefix::String #File prefix for the atmospheric netcdf files
  oceanFilePrefix::String #File prefix for the ocean netcdf files
  uvar::String #The name of the variable U inside the netcdf
  vvar::String #The name of the variable V inside the netcdf
  ELE::Array{Int64,2} #Nodes of an element
  E2E5::Array{Float64,2} #table of the elements that surround an element at 5 levels
  N2E::Array{Float64,2} #Table of the elements that surround a node
  CostaX::Array{Float64,2} #Node longitud of Coastline of mesh defined by FORT.14 (Longitude)
  CostaY::Array{Float64,2} #Node latitude of Coastline of mesh defined by FORT.14 (Latitude)
  TR::Array{GeometricalPredicates.UnOrientedTriangle{Point2D},1} #Array of triangles
  MeshInterp::Array{Float64,2} #Interp object for future interpolation

end

type OilSpillDataMultiple
  dates::DateTime
  barrells::Array{Int64,1}
  depths::Array{Int64,1}
  lat::Array{Float64,1}
  lon::Array{Float64,1}
  barrellsPerParticle::Int64
end

type DailySpill
  date::DateTime
  net::Array{Int64,1}
  surface::Array{Float64,1}
  subSurf::Array{Float64,1}
  burned::Array{Float64,1}
  evaporated::Array{Float64,1}
  collected::Array{Float64,1}
  surfaceNatrDispr::Array{Float64,1}
  surfaceChemDispr::Array{Float64,1}
end
