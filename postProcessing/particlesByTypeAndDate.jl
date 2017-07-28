function particlesByTypeAndDate(particles::Array{Particle,1})
  allTypes = Array{Int64}(length(particles))

  for particle in 1:length(particles)
    allTypes[particle] = particles[particle].component
  end
  Types = unique(allTypes)

  totTypes = [find(x -> x == Types[types],allTypes) for types in 1:length(Types)]

  particlesByType = Array{Array{Particle}}(length(Types))
  for types in length(totTypes)
    particlesByType[types] = particles[totTypes[types]]
  end
  println(length(particlesByType))
end
