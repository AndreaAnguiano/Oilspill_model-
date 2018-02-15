

function main()
#----initial conditions----

#-------spill timing (yyyy, mm, dd)------
  Days = 5   #days of spill
  startDate = DateTime(2010,04,30)
  endDate =startDate + Dates.Day(Days)
#----- spill location ------------------
  depths = [0, 400,1000]
  lat = [28.0]
  lon = [-88.0]
  positions = [[28, -88], [20, -95]]

#----------- Oil components per depth ------------
  components = [0.05 0.05 0.05 0.05 0.1 0.2 0.2 0.3; 0.05 0.05 0.1 0.1 0.1 0.2 0.2 0.2; 0.05 0.2 0.3 0.2 0.1 0.05 0.05 0.05; ]
#------------------Distribution of oil per depth -------------
  subSurfaceFraction = [0, 2/3, 1/3]
#------------ total components----------------
  totComponents = 8
#----------- wind fraction-----------------------
  windContrib = 0.035
#------turbulent-difussion parameter at surface-------
  turbulentDiff = 0.2
#----------------lagrangian time  step (h) ----------
  timeStep = 12
#------------ oil decay ----------------------------
  diffusion = 0.005
#-------------evaporation --------------------
  evaporate = [1]
#------------biodegradation ------------------
  biodeg = [1]
#------------- burning -------------------------
  burned = [1]
#------- collection ------------------------
  collected = [1]
#---------exponential degradation-----------------
  expDegradePercentage = 95
  byComponent = threshold(expDegradePercentage,[4, 8, 12, 16, 20, 24, 28, 32], timeStep)
#----------------- decay type ----------------
  decay = Decay(burned,collected, evaporate, biodeg, byComponent)
#------------- init part size ----------------
  initPartSize = 10
#----- number of barrells represented by one particle
  barrellsPerParticle = 100
#----- arrays for initialize OilSpillModel type
  ArrVF1 = zeros(3)
  ArrVF3 = zeros(3,3,3) # Initial array for vectorFields 3x3
  ArrVF2 = zeros(3,2) # Initial array for vectorFields 3x2
  ArrIntVF2 = ones(Int64,1,1)
  ArrIntVF1 = ones(Int64,1)
  ArrDepthIndx = zeros(length(depths),2)
  ArrTR = GeometricalPredicates.UnOrientedTriangle{Point2D}[]
#------- visualization of particles -------------
  visualize = true
  lims = [-97 -80; 20 31] #limits for visualization
# ------------ type of oceanic model (hycom | adcirc) ---------
  model = "hycom"
#---------------- reading 3 dimensions data (x, y, z) in vectorFields -----
  VF3D = false
#----------------- type of spill ( oil | multiple)
  spillType = "oil"
#------------------ get statistics from particles ------------------
  Statistics = false

  if spillType == "simple" #multiple oil spills
    FileName = "/home/andrea/Data/Datos/ndatos_derrame.csv"
    lims = [-98 -80; 18 31]
  else #one oil spill from Oil Budget Calculator (2010)
    FileName = "/home/andrea/Data/Datos/spill_data.csv"
  end
#------ model configurations ----------------
  modelConfigs = modelConfig(startDate,endDate, depths, components, subSurfaceFraction, decay, timeStep, initPartSize, totComponents, windContrib, turbulentDiff, diffusion, model, spillType)
#---- initializing the model ------------------
  particles = oilSpillModel(modelConfigs, FileName, ArrVF3, ArrVF2, ArrVF1,ArrIntVF2,ArrIntVF1,ArrTR, ArrDepthIndx, startDate, endDate, visualize, timeStep, lat, lon, VF3D, positions, barrellsPerParticle, lims, Statistics)

#------ saving positions of the particles  ----------
  savePostions = false
  if savePositions
    savePositions(particles, Days)
  end
end

main()
#-------profilling and timing ---------
# Profile.clear()
# Profile.init(delay = 0.02)
# @profile main()
#using ProfileView
#ProfileView.view()

#@time main()
