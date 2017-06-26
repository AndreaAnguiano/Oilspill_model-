function oilSpillModel(modelConfigs, FileName, ArrVF3, ArrVF2, ArrVF1, startJulianDate, endJulianDate, visualize, deltaT)
  #Start of all fields with the initial conditions
  spillData = readData(FileName) #Reading all the values of the spill
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
          if modelConfigs.model == "hycom"
            atmFilePrefix = "Dia_" #File prefix for the atmospheric netcdf files
            oceanFilePrefix = "archv.2010_" #File prefix for the ocean netcdf files

            vF = VectorFields(deltaT,currHour,currDay, VF, modelConfigs, atmFilePrefix, oceanFilePrefix)

            println("CurrHour = ", currHour, " CurrDay = ", currDay )
            #Advecting particles

            Particles = advectParticles(VF, modelConfigs, particles, currDate)
            #DegradingParticles
            Particles  = oilDegradation(particles, modelConfigs, spillData, particlesByTimeStep)

          elseif modelConfigs.model == "adcirc"
            atmFilePrefix  = "fort.74." # File prefix for the atmospheric netcdf files
            oceanFilePrefix  = "fort.64." # File prefix for the ocean netcdf files
            uvar = "u-vel"
            vvar = "v-vel"
            vF = VectorFieldsADCIRC(deltaT,currHour,currDay,VF, modelConfigs, atmFilePrefix, oceanFilePrefix, uvar, vvar)
            println("CurrHour = ", currHour, " CurrDay = ", currDay )
          end
        end
        if visualize
          LiveParticlesIndx = find(obj -> obj.isAlive == true, particles)
          DeadParticlesIndx = find(obj -> obj.isAlive == false, particles)

          lastLat = [particles[ind].lat[end] for ind in LiveParticlesIndx]
          lastLon = [particles[ind].lon[end] for ind in LiveParticlesIndx]
          lastDepth = [particles[ind].depths[end] for ind in LiveParticlesIndx]


          Plots.scatter3d(lastLon, lastLat, lastDepth)
          gui()
        end
      end
  end
end
