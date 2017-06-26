using Plots
#----initial conditions----
Days = 5

startDate = DateTime(2010,04,23)
endDate =startDate + Dates.Day(Days)


depths = [0, 500, 1000]
components = [0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.3; 0.0 0.0 0.0 0.1 0.1 0.1 0.2 0.5; 0.0 0.0 0.0 0.0 0.0 0.1 0.2 0.7; ]
subSurfaceFraction = [1/3, 2/3]
timeStep = 6
initPartSize = 10
totComponents = 8
windContrib = 0.035
turbulentDiff = 1.0
diffusion = 0.005
evaporate = [1]
biodeg = [1]
burned = [1]
collected = [1]
byComponent = threshold(95,[4, 8, 12, 16, 20, 24, 28, 32], timeStep)
FileName = "/media/petroleo/Datos/datos_derrame.csv"
ArrVF1 = zeros(3)
ArrVF3 = zeros(3,3,3) # Initial array for vectorFields 3x3
ArrVF2 = zeros(3,2) # Initial array for vectorFields 3x2
startJulianDate = toJulianDate(startDate)
endJulianDate = toJulianDate(endDate)
decay = Decay(burned,collected, evaporate, biodeg, byComponent)
lat = [28.0]
lon = [-88.0]
deltaT = 3
visualize = false
model = "adcirc"

modelConfigs = modelConfig(startDate,endDate, depths, lat, lon, components, subSurfaceFraction, decay, timeStep, initPartSize, totComponents, windContrib, turbulentDiff, diffusion, model)

oilSpillModel(modelConfigs, FileName, ArrVF3, ArrVF2, ArrVF1, startJulianDate, endJulianDate, visualize, deltaT)
#
# Profile.clear()
 #Profile.init(delay = 0.02)
 #@profile main()
#using ProfileView
#ProfileView.view()
#@time main()
#
#
