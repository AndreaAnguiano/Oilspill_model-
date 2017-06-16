
function SplitByTimeStep(ParticlesByTimeStep, spillData, modelConfigs, Day)
  currDateIdx = find(obj -> toJulianDate(obj.dates) == Day, spillData)
  fractByTimeStep = modelConfigs.timeStep/24
  barrellsPerParticle = spillData[currDateIdx][1].barrellsPerParticle

  ParticlesByTimeStep.particles = ceil(fractByTimeStep.*(spillData[currDateIdx][1].barrells[1]/barrellsPerParticle))
  ParticlesByTimeStep.partSub = ceil(modelConfigs.subSurfaceFraction*fractByTimeStep.*(spillData[currDateIdx][1].barrells[2:end]./barrellsPerParticle))
  ParticlesByTimeStep.burned = ceil(fractByTimeStep*(spillData[currDateIdx][1].burned/barrellsPerParticle))
  ParticlesByTimeStep.evaporated = ceil(fractByTimeStep*(spillData[currDateIdx][1].evaporate/barrellsPerParticle))
  ParticlesByTimeStep.recovered = ceil(fractByTimeStep*(spillData[currDateIdx][1].collected/barrellsPerParticle))

end
