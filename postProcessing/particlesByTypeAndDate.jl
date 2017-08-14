using Plots
plotlyjs()

function particlesByTypeAndDate(particles::Array{Particle,1})
  allTypes = Array{Int64}(length(particles))

  for particle in 1:length(particles)
    allTypes[particle] = particles[particle].component
  end
  Types = unique(allTypes)
  TypeAndDates = zeros(Float64,length(Types))

  for types in 1:length(Types)
    indxTypes = find(x-> x.component == Types[types], particles)
    subPart = particles[indxTypes]
    TypeAndDates[types] = mean([x.currTimeStep for x in subPart])
  end
  typesString = ["Type 1", "Type 2", "Type 3", "Type 4", "Type 5", "Type 6", "Type 7", "Type 8"]
  plotByTypeAndDate(typesString, TypeAndDates)
end
