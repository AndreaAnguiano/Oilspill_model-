#constructor that contains all the values for the spill
type OilSpillData
  dates::DateTime
  barrells::Array
  evaporate::Int64
  burned::Int64
  collected::Int64
  depths::Array
  barrellsPerParticle::Int64
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
  lat::Array{Float64,1} #latitude of the spill
  lon::Array{Float64,1} #longitude of the spill
  components::Array{Float64,2} #Array of components for each depth
  subSurfaceFraction::Array{Float64,1} #Array with the fraction of oil spilled at each subsurface depth
  decay::Decay
  timeStep::Int64 #The time step is in hours and should be exactly divided by 24
  initPartSize::Int64 #How big does we initialize the vector size of particles lats, lons, etc
  totComponents::Int64 #Total number of components
  windContrib::Float64 #The percentaje contribution of the wind into the model
  turbulentDiff::Float64 #Value of turbulent diffusion (When advecting particles)
  diffusion::Float64 #Variance of the diffusion (in degrees) when initializing particles
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
  currDay::Int64 #Current day of the model
  currHour::Int64 #Current hour of the model
  lat::Array{Float64,1}
  lon::Array{Float64,1}
  depths::Array{Float64,1} #Array of depths corresponding to U and V
  depthsMinMax::Array{Int64,1} #Array of indexes corresponding to the minumum and maximum depth of the particles
  depthsIndx::Array{Int64,2} #Array of indexes corresponding to closest indexes at each depth of the particles
end

type ParticlesByTimeStep
  particles::Float64
  partSub::Array{Float64,1}
  burned::Float64
  evaporated::Float64
  recovered::Float64
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
