function oilSpillModel(dataPath::String, configPath::String, modelConfigs::modelConfig, FileName::String,
                       ArrVF3, ArrVF2, ArrVF1,ArrIntVF2,ArrIntVF1, ArrTR,ArrDepthIndx,
                        startDate, endDate, visualize, deltaT, lat, lon,VF3D,positions,
                        barrellsPerParticle::Float64, lims, Statistics)
  #----------Starting all fields with the initial conditions----------
  #----------initalizing the oilSpill type --------------------
  spillData::Array{OilSpillData} = []
  if modelConfigs.spillType == "oil"
    spillData = oilSpillData(FileName, lat, lon, barrellsPerParticle = barrellsPerParticle) #Reading all the values of the spill
    positions = [positions[1]]
  elseif modelConfigs.spillType == "simple"
    spillData = oilSpillDataMultiple(FileName)
  end
   #---------------- Initializing empty VF and VFCIRC type  -----------------
  VF::vectorFields = vectorFields(ArrVF3,ArrVF3,ArrVF3,ArrVF3,ArrVF2,ArrVF2,ArrVF2,ArrVF2,ArrVF2,ArrVF2,ArrVF2,ArrVF2,ArrVF2,ArrVF2,ArrVF3,ArrVF3,ArrVF3,ArrVF3,ArrVF3,ArrVF3,ArrVF2,ArrVF2,ArrVF2,ArrVF2,ArrVF2,ArrVF2,
                   toJulianDate(startDate),0, lat, lon, [], [], ArrVF1,ArrVF1,ArrDepthIndx,ArrVF2, [1 1; 1 1])

  VFADCIRC::VectorFieldsADCIRC = VectorFieldsADCIRC(ArrVF2,ArrVF2,ArrVF2,ArrVF2,ArrVF2,ArrVF2,ArrVF2,ArrVF2,ArrVF2,ArrVF2,ArrVF2,ArrVF2,toJulianDate(startDate),0,lat,lon, ArrVF1, ArrVF1, ArrVF2,
   "atmFilePrefix", "oceanFilePrefix", "uvar", "vvar", ArrIntVF2,ArrIntVF2,ArrIntVF2, ArrVF2, ArrVF2,ArrTR,ArrVF2 )
  #-----------Initializing empty particlesByTimeStep array--------------
  particlesByTimeStep = ParticlesByTimeStep[]
  #------------ Initializing empty array of particles ------------------
  particles = Particle[]
  advectingParticles = false

  if visualize
    plotGulf(configPath, lims)
  end
   for currDay in (startDate:Dates.Day(1):endDate)
    #Verify we have some data in this day
    if any(obj -> obj.dates == currDay, spillData)
      advectingParticles = true #We should start to reading vector fields and advectingParticles
      #Read from spilldata and init proper number of particles
    # -------------- #get daily spill quantities for position (in case of multiple spills)
      for position in range(1,length(positions))
        splitByTimeStep = SplitByTimeStep(particlesByTimeStep, spillData, modelConfigs, currDay)
      end

    end

      for currHour in range(0,deltaT,convert(Int64,24/deltaT))

        if advectingParticles
    #-------------
          for position in range(1,length(positions))
            particles = initParticles(particles, spillData, particlesByTimeStep[position], modelConfigs, currDay, currHour)
          end
          if modelConfigs.model == "hycom"
            atmFilePrefix = "Dia_" #File prefix for the atmospheric netcdf files
            oceanFilePrefix = "archv.2010_" #File prefix for the ocean netcdf files
            if VF3D
              vF = VectorFields3D(deltaT,currHour,currDay, VF, modelConfigs, atmFilePrefix, oceanFilePrefix)
              #println("CurrHour = ", currHour, " CurrDay = ", currDay)
              #Advecting particles
              particles = advectParticles3D(VF, modelConfigs, particles, currDay)
              #DegradingParticles
              particles  = oilDegradation(particles, modelConfigs, spillData, particlesByTimeStep, lat, lon)

            else
                vF = VectorFields2(dataPath, deltaT,currHour,currDay, VF, modelConfigs, atmFilePrefix, oceanFilePrefix)
                # vF = @enter VectorFields2(dataPath, deltaT,currHour,currDay, VF, modelConfigs, atmFilePrefix, oceanFilePrefix)
                #println("CurrHour = ", currHour, " CurrDay = ", currDay)
                #Advecting particles
                # particles = @enter advectParticles2(VF, modelConfigs, particles, currDay)
                particles = advectParticles2(VF, modelConfigs, particles, currDay)
                #DegradingParticles
                for position in range(1,length(positions))
                    LiveParticles::Array{Int64,1} = find(obj -> obj.isAlive == true, particles)
                    particles  = oilDegradation(particles, modelConfigs, spillData, particlesByTimeStep[position])
                end
            end

          else modelConfigs.model == "adcirc"
            atmFilePrefixADCIRC  = "fort.74." # File prefix for the atmospheric netcdf files
            oceanFilePrefixADCIRC  = "fort.64." # File prefix for the ocean netcdf files
            uvar = "u-vel"
            vvar = "v-vel"
            vF = vectorFieldsADCIRC(deltaT,currHour,currDay,VFADCIRC, modelConfigs, atmFilePrefixADCIRC, oceanFilePrefixADCIRC, uvar, vvar)
            #println("CurrHour = ", currHour, " CurrDay = ", currDay )
            particles = advectParticlesADCIRC(VFADCIRC, modelConfigs, particles, currDay)


          end
        end
        if visualize
          LiveParticlesIndx = find(obj -> obj.isAlive == true, particles)

          lastLat = [particles[ind].lat[end] for ind in LiveParticlesIndx if particles[ind].depths == [0]]
          lastLon = [particles[ind].lon[end] for ind in LiveParticlesIndx if particles[ind].depths == [0]]
          lastDepth = [particles[ind].depths[end] for ind in LiveParticlesIndx if particles[ind].depths == [0]]
          plotParticles2D(lastLon, lastLat)
          if currHour == 12
            #savefig("$currHour-$currDay")
          end
          gui()

        end

      end
  end

  if Statistics
    modelStatistics(particles,[28.0 -88.0; 38.0 -88.0; 37.8 -88], 10.0 )
  end

  return particles
end
