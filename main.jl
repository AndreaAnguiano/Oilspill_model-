using PyPlot
function main()
  #----initial conditions----
  Days = 5
  startDate = DateTime(2010,05,01)
  endDate = DateTime(2010,05,01) + Dates.Day(Days)
  path = "Datos/"
  depths = [0, 300, 1000]
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
  FileName = "datos_derrame.csv"
  ArrVF1 = zeros(3)
  ArrVF3 = zeros(3,3,3) # Initial array for vectorFields 3x3
  ArrVF2 = zeros(3,2) # Initial array for vectorFields 3x2
  startJulianDate = toJulianDate(startDate)
  endJulianDate = toJulianDate(endDate)
  decay = Decay(burned,collected, evaporate, biodeg, byComponent)
  lat = [28.0]
  lon = [-88.0]
  deltaT = 12
  visualize = true

  modelConfigs = modelConfig(startDate,endDate, depths, lat, lon, components, subSurfaceFraction, decay, timeStep, initPartSize, totComponents, windContrib, turbulentDiff, diffusion)
  #Start of all fields with the initial conditions
  spillData = readData("Datos/"FileName) #Reading all the values of the spill
  VF = vectorFields(ArrVF3,ArrVF3,ArrVF3,ArrVF3,ArrVF2,ArrVF2,ArrVF2,ArrVF2,ArrVF2,ArrVF2,ArrVF2,ArrVF2,startJulianDate,0,lat,lon, ArrVF1, ArrVF1, ArrVF2) #Initial vectorfield
  particlesByTimeStep = ParticlesByTimeStep(0.0,[0.0], 0.0, 0.0, 0.0) #Initial particlesByTimeStep
  particles = Particle[]  #Start array of particles empty
  advectingParticles = false

   for currDay in range(startJulianDate, 1, endJulianDate-startJulianDate) #
    #Verify we have some data in this day
    if any(obj -> toJulianDate(obj.dates) == currDay, spillData)
      advectingParticles = true #We should start to reading vector fields and advectingParticles
      #Read from datos_derrame and init proper number of particles
      splitByTimeStep = SplitByTimeStep(particlesByTimeStep, spillData, modelConfigs, currDay)
    end
      for currHour in range(0,deltaT,convert(Int64,24/deltaT))
        currDate = DateTime(Dates.year(modelConfigs.startDate),12,31, currHour, 0, 0) + Dates.Day(currDay)
        if advectingParticles

          Particles = initParticles(particles, spillData, particlesByTimeStep, modelConfigs, currDay, currHour)
          VF = readUV(deltaT,currHour,currDay,VF, modelConfigs)
          println("CurrHour = ", currHour, " CurrDay = ", currDay )
          #Advecting particles
          Particles = advectParticles(VF, modelConfigs, particles, currDate)
          #DegradingParticles
          Particles  = oilDegradation(particles, modelConfigs, spillData, particlesByTimeStep)
        end
        if visualize
          LiveParticlesIndx = find(obj -> obj.isAlive == true, particles)
          DeadParticlesIndx = find(obj -> obj.isAlive == false, particles)

          lastLat = [particles[ind].lat[end] for ind in LiveParticlesIndx]
          lastLon = [particles[ind].lon[end] for ind in LiveParticlesIndx]
          lastDepth = [particles[ind].depths[end] for ind in LiveParticlesIndx]

          fig = figure("pyplot_scatterplot",figsize=(10,10))
          ax = axes()
          grid("on")
          scatter3D(lastLon, lastLat, lastDepth)

        end
      end

  end
end
main()
# Profile.clear()
# @profile main()
# ProfileView.view()
@time main()
