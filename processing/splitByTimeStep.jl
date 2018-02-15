
function SplitByTimeStep(particlesByTimeStep, spillData, modelConfigs, Day)
  currDateIdx = find(obj -> obj.dates == Day, spillData)
  fractByTimeStep = modelConfigs.timeStep/24


  for DateIdx in range(1,length(currDateIdx))
    push!(particlesByTimeStep,ParticlesByTimeStep(0.0, [0.0], 0.0, 0.0, 0.0,[0.0],[0.0]))


    barrellsPerParticle = spillData[currDateIdx][DateIdx].barrellsPerParticle
    particlesByTimeStep[DateIdx].particles = roundStat(fractByTimeStep.*(spillData[currDateIdx][DateIdx].barrells[DateIdx]/barrellsPerParticle))
    particlesByTimeStep[DateIdx].partSub = roundStat.(modelConfigs.subSurfaceFraction*fractByTimeStep.*(spillData[currDateIdx][DateIdx].subsurfDispersants./barrellsPerParticle))
    particlesByTimeStep[DateIdx].lat = spillData[currDateIdx][DateIdx].lat
    particlesByTimeStep[DateIdx].lon = spillData[currDateIdx][DateIdx].lon
    if modelConfigs.spillType == "oil"
      particlesByTimeStep[DateIdx].burned = roundStat(fractByTimeStep*(spillData[currDateIdx][DateIdx].burned/barrellsPerParticle))
      particlesByTimeStep[DateIdx].evaporated = roundStat(fractByTimeStep*(spillData[currDateIdx][DateIdx].evaporate/barrellsPerParticle))
      particlesByTimeStep[DateIdx].recovered = roundStat(fractByTimeStep*(spillData[currDateIdx][DateIdx].collected/barrellsPerParticle))
    elseif modelConfigs.spillType == "simple"
      particlesByTimeStep[DateIdx].burned = 0
      particlesByTimeStep[DateIdx].evaporated = 0
      particlesByTimeStep[DateIdx].recovered = 0

    end
  end
end
