function initParticles(particles, spillData, particlesByTimeStep, modelConfig, currDay, currHour)

  idxPart = length(particles) + 1  #Index of the total number of particles
  totComp = length(modelConfig.components[1,:])

  idxDepth = 1 #Auxiliar index of the current depth
  particlesByDepth = zeros(size(modelConfig.components))
  for depth = modelConfig.depths

    if depth == 0
      particlesByDepth[idxDepth,:] = ceil(modelConfig.components[idxDepth,:].*particlesByTimeStep.particles)
    else

       particlesByDepth[idxDepth,:] = ceil(modelConfig.components[idxDepth,:].*particlesByTimeStep.partSub[idxDepth-1])
     end
    idxDepth = idxDepth + 1
   end
# #
  for depthIdx = 1:length(modelConfig.depths)
    for component = 1:totComp
      for numPart = 0:particlesByDepth[depthIdx, component]
        push!(particles, Particle([currDay], copy(modelConfig.lat), copy(modelConfig.lon), [copy(modelConfig.depths[depthIdx])], 0,copy(component), 1, true, "M"))
        idxPart += 1
      end
    end
   end
 end
