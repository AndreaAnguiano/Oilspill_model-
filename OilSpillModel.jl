

function oilSpillModel(modelConfigs, FileName, ArrVF3, ArrVF2, ArrVF1,ArrIntVF2,ArrIntVF1, ArrTR, startDate, endDate, visualize, deltaT, lat, lon)
  #Start of all fields with the initial conditions
  spillData = OilSpillData(FileName) #Reading all the values of the spill
  VF = vectorFields(ArrVF3,ArrVF3,ArrVF3,ArrVF3,ArrVF2,ArrVF2,ArrVF2,ArrVF2,ArrVF2,ArrVF2,ArrVF2,ArrVF2,ArrVF2,ArrVF2,ArrVF3,ArrVF3,ArrVF3,ArrVF3,ArrVF3,ArrVF3,ArrVF2,ArrVF2,ArrVF2,ArrVF2,ArrVF2,ArrVF2, toJulianDate(startDate),0, lat, lon, ArrVF1,ArrVF1,ArrVF2,ArrVF2) #Initial vectorfield
  VFADCIRC = VectorFieldsADCIRC(ArrVF2,ArrVF2,ArrVF2,ArrVF2,ArrVF2,ArrVF2,ArrVF2,ArrVF2,ArrVF2,ArrVF2,ArrVF2,ArrVF2,toJulianDate(startDate),0,lat,lon, ArrVF1, ArrVF1, ArrVF2, "atmFilePrefix", "oceanFilePrefix", "uvar", "vvar", ArrIntVF2,ArrIntVF2,ArrIntVF2, ArrVF2, ArrVF2,ArrTR,ArrVF2 )

  particlesByTimeStep = ParticlesByTimeStep(0.0,[0.0], 0.0, 0.0, 0.0) #Initial particlesByTimeStep
  particles = Particle[]  #Start array of particles empty
  advectingParticles = false

   for currDay in (startDate:Dates.Day(1):endDate) #
    #Verify we have some data in this day
    if any(obj -> obj.dates == currDay, spillData)
      advectingParticles = true #We should start to reading vector fields and advectingParticles
      #Read from datos_derrame and init proper number of particles
      splitByTimeStep = SplitByTimeStep(particlesByTimeStep, spillData, modelConfigs, currDay)

    end
      for currHour in range(0,deltaT,convert(Int64,24/deltaT))
        if advectingParticles
          Particles = initParticles(particles, spillData, particlesByTimeStep, modelConfigs, currDay, currHour)
          if modelConfigs.model == "hycom"
            atmFilePrefix = "Dia_" #File prefix for the atmospheric netcdf files
            oceanFilePrefix = "archv.2010_" #File prefix for the ocean netcdf files

            vF = VectorFields2(deltaT,currHour,currDay, VF, modelConfigs, atmFilePrefix, oceanFilePrefix)
            println("CurrHour = ", currHour, " CurrDay = ", currDay)
            #Advecting particles

            Particles = advectParticles2(VF, modelConfigs, particles, currDay)
            #DegradingParticles
            Particles  = oilDegradation(particles, modelConfigs, spillData, particlesByTimeStep)

          elseif modelConfigs.model == "adcirc"
            atmFilePrefixADCIRC  = "fort.74." # File prefix for the atmospheric netcdf files
            oceanFilePrefixADCIRC  = "fort.64." # File prefix for the ocean netcdf files
            uvar = "u-vel"
            vvar = "v-vel"
            vF = vectorFieldsADCIRC(deltaT,currHour,currDay,VFADCIRC, modelConfigs, atmFilePrefixADCIRC, oceanFilePrefixADCIRC, uvar, vvar)
            println("CurrHour = ", currHour, " CurrDay = ", currDay )
            Particles = advectParticlesADCIRC(VFADCIRC, modelConfigs, particles, currDay)


          end
        end
        if visualize
          LiveParticlesIndx = find(obj -> obj.isAlive == true, particles)
          DeadParticlesIndx = find(obj -> obj.isAlive == false, particles)

          lastLat = [particles[ind].lat[end] for ind in LiveParticlesIndx]
          lastLon = [particles[ind].lon[end] for ind in LiveParticlesIndx]
          lastDepth = [particles[ind].depths[end] for ind in LiveParticlesIndx]
          plotParticles(lastLon, lastLat, lastDepth)
          gui()

        end
      end
  end
  return particles
end
