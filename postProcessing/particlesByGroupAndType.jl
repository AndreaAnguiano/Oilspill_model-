using Plots
plotlyjs()
#grupo en el caso del petroleo son evaporadas, quemadas, etc. Y tipo, son los componentes del petroleo.

function particlesByGroup(particles::Array{Particle,1})
  allGroups = Array{String}(length(particles))
  allTypes = Array{Int64}(length(particles))

  for particle in 1:length(particles)
    allGroups[particle] = particles[particle].status
    allTypes[particle] = particles[particle].component
  end
  Groups = unique(allGroups)
  Types = unique(allTypes)

  GroupsAll =[length(find(x -> x == Groups[group],allGroups)) for group in 1:length(Groups)]
  GroupsAndTypes = zeros(Int64, length(Groups), length(Types))
  TypesAll =[length(find(x -> x == Types[types], allTypes)) for types in 1:length(Types)]

  for group in 1:length(Groups)
    indxStatus = find(x-> x.status == Groups[group], particles)
    subPart = particles[indxStatus]
      for typ in 1:length(Types)
        indxComp = find(x-> x.component == Types[typ], particles)
        GroupsAndTypes[group,typ] = length(indxComp)
      end
  end
  typesString = ["Type 1", "Type 2", "Type 3", "Type 4", "Type 5", "Type 6", "Type 7", "Type 8"]
  plotByType(typesString, TypesAll)
  #savefig("ParticlesByOilType")
  plotByGroupAndType(Groups, GroupsAndTypes)
  gui()
end
