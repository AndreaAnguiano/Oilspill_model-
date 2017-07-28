function oilDegradation(particles, modelConfigs, spillData, particlesByTimeStep)

#Verify that we need to dregade something
  if modelConfigs.decay.evaporate == [1] || modelConfigs.decay.biodeg == [1] || modelConfigs.decay.burned == [1] || modelConfigs.decay.collected == [1]

    #Define the number of particles we need to degradate
    parts_evaporated = 0
    parts_burned = 0
    parts_collected = 0
    burning_radius = 3

    #Get the live particles
    LiveParticles = find(obj -> obj.isAlive == true, particles)

    #How many particles we have
    numParticles = length(LiveParticles)

    #Ordered indexes
    particlesIndex = convert(Array,1:numParticles)

    #Degradated
    if modelConfigs.decay.biodeg == [1]

      #Select all the components for the live particles
      allComponents = [particles[idx].component for idx in LiveParticles]

      #Choose how many will be biodegradated
      partToKill = find(rand(1, numParticles)[1,:] .> [modelConfigs.decay.byComponent[idx] for idx in allComponents])

      #Modify the selected particles
      for finalIndex = partToKill#find(obj -> obj == true, partToKill)
          particles[LiveParticles[finalIndex]].isAlive = 0
          particles[LiveParticles[finalIndex]].status = "D"
       end

       #Remove the particles that have been already degraded

       particlesIndex = deleteat!(particlesIndex, partToKill)

    end
    random_particles = particlesIndex[randperm(length(particlesIndex))]

    #compute the number of particles to evaporate, burn and recover (statistically) from fractional value
    toEvaporate = floor(particlesByTimeStep.evaporated) + ((particlesByTimeStep.evaporated - floor(particlesByTimeStep.evaporated)) .> rand(1))
    toBurn = floor(particlesByTimeStep.burned) + ((particlesByTimeStep.burned - floor(particlesByTimeStep.burned)) .> rand(1))
    toRecover = floor(particlesByTimeStep.recovered) + ((particlesByTimeStep.recovered - floor(particlesByTimeStep.recovered)) .> rand(1))

    for partIndx = random_particles
      component_p = particles[LiveParticles[partIndx]].component
      #Evaporated
      if modelConfigs.decay.evaporate == [1] && parts_evaporated < toEvaporate[1] && component_p in 1:4
        particles[LiveParticles[partIndx]].isAlive = 0
        particles[LiveParticles[partIndx]].status = "E"
        parts_evaporated = parts_evaporated + 1
      #Burned
      elseif modelConfigs.decay.burned == [1] && parts_burned <  toBurn[1]
        #Calculate the distance from source
        ind = particles[LiveParticles[partIndx]].currTimeStep
        lat_p = particles[LiveParticles[partIndx]].lat[ind]
        lon_p = particles[LiveParticles[partIndx]].lon[ind]
        #Haversine formula
        delta_lat = deg2rad.(lat_p - modelConfigs.lat)
        delta_lon = deg2rad.(lon_p - modelConfigs.lon)
        a = sin(delta_lat[1]/2)^2 + cos(deg2rad(lat_p))*cos(deg2rad.(modelConfigs.lat[1]))*sin(delta_lon[1]/2)^2
        c = 2*atan(sqrt(a))*atan(sqrt(1-a))
        distanceFromSource = 6371e+03/1000 * c
        if distanceFromSource <= burning_radius
          particles[LiveParticles[partIndx]].isAlive = 0
          particles[LiveParticles[partIndx]].status = "B"
          parts_burned = parts_burned + 1
        end
      #Collected
      elseif modelConfigs.decay.collected == [1] && parts_collected < toRecover[1]
        particles[LiveParticles[partIndx]].isAlive = 0
        particles[LiveParticles[partIndx]].status = "C"
        parts_collected = parts_collected + 1

      else
        #If we get here, then we do not need to degrade any more particles
        break
      end
    end
  end
end #End oil decay
