#----initial conditions----
#Spill location
lat = [19.1965]
lon = [-96.08]

#Spill timing (yy, mm, dd)
Days = 40
startDate = DateTime(2010,05,01)
endDate =startDate + Dates.Day(Days)
#Model type
modelType = 'adcirc'
#Oil barrels representing one particle
barrelsPerParticle = 500
#Lagrangian time step (h)
timeStep = 2
#Simulation depths
depths = [0]
#Oil classes proportions per depth
components = [0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.3]
totComponents = length(components)
#2 std for random initialization of particles
diffusion = 0.05
#Turbulent-diffusion parameter per depth
turbulentDiff = 1.0
#Wind fraction used to advect particles (only for 0 m depth)
windContrib = 0.035
#Distribution of oil per subsurface depth
subSurfaceFraction = [1/5]
#Oil decay
evaporate = [1]
biodeg = [1]
burned = [1]
collected = [1]
byComponent = threshold(95,[4, 8, 12, 16, 20, 24, 28, 32], timeStep)
#File name wich contains the spill information
FileName = "/media/petroleo/Datos/datos_derrame.csv"
#arrays for VectorFields
ArrVF1 = zeros(3)
ArrVF3 = zeros(3,3,3) # Initial array for vectorFields 3x3
ArrVF2 = zeros(3,2) # Initial array for vectorFields 3x2
#Dates
startJulianDate = toJulianDate(startDate)
endJulianDate = toJulianDate(endDate)
#Initial type decay
decay = Decay(burned,collected, evaporate, biodeg, byComponent)

deltaT = 3
visualize = true
