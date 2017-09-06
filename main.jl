
#----initial conditions----
function main()
  Days = 20
  startDate = DateTime(2010,04,25)
  endDate =startDate + Dates.Day(Days)
  depths = [0, 800,1000]
  components = [0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.3; 0.0 0.0 0.0 0.1 0.1 0.1 0.2 0.5; 0.0 0.0 0.0 0.0 0.0 0.1 0.2 0.7; ]
  subSurfaceFraction = [1/3, 1/3, 1/3]
  initPartSize = 10
  totComponents = 8
  windContrib = 0.035
  turbulentDiff = 1.0
  diffusion = 0.005
  evaporate = [1]
  biodeg = [1]
  burned = [1]
  collected = [1]
  timeStep = 12
  byComponent = threshold(95,[4, 8, 12, 16, 20, 24, 28, 32], timeStep)
  FileName = "/media/petroleo/Datos/datos_derrame.csv"
  ArrVF1 = zeros(3)
  ArrVF3 = zeros(3,3,3) # Initial array for vectorFields 3x3
  ArrVF2 = zeros(3,2) # Initial array for vectorFields 3x2
  ArrIntVF2 = ones(Int64,1,1)
  ArrIntVF1 = ones(Int64,1)
  ArrDepthIndx = zeros(length(depths),2)
  ArrTR = GeometricalPredicates.UnOrientedTriangle{Point2D}[]
  #startJulianDate = toJulianDate(startDate)
  #endJulianDate = toJulianDate(endDate)
  decay = Decay(burned,collected, evaporate, biodeg, byComponent)
  lat = [28.0]
  lon = [-88.0]
  visualize = true
  model = "hycom"
  VF3D = false

  modelConfigs = modelConfig(startDate,endDate, depths, lat, lon, components, subSurfaceFraction, decay, timeStep, initPartSize, totComponents, windContrib, turbulentDiff, diffusion, model)

  particles = oilSpillModel(modelConfigs, FileName, ArrVF3, ArrVF2, ArrVF1,ArrIntVF2,ArrIntVF1,ArrTR, ArrDepthIndx, startDate, endDate, visualize, timeStep, lat, lon, VF3D)
  #particlesByLocation(particles, [28.0 -88.0; 38.0 -88.0; 37.8 -88], 10.0)
  #particlesByGroup(particles)



end
main()
# Profile.clear()
# Profile.init(delay = 0.02)
# @profile main()
#using ProfileView
#ProfileView.view()
#@time main()








#
