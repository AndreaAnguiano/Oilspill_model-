using Plots
pyplot()
#grupo en el caso del petroleo son evaporadas, quemadas, etc. Y tipo, son los componentes del petroleo.

function particlesByGroup(particles::Array{Particle,1})

  allGroups = Array{String}(length(particles))
  allTypes = Array{Int64}(length(particles))

  for particle in 1:length(particles)
    allGroups[particle] = particles[particle].status
    allTypes[particle] = particles[particle].component
  end
  Groups = unique(allGroups)
  totGroups = Array{Array{Int64}}(length(Groups))
  Types = unique(allTypes)

  for group in 1:length(Groups)
    totGroups[group] = find(x -> x == Groups[group], allGroups)
  end

  totGroupsAndTypes = Array{Array{Int64}}(length(Groups))
  for group in totGroups
    tempType = Array{Array{Int64}}(length(group))
    for typ in Types
      tempType[typ] = find(x -> x == Types[typ], group)
    end
    totGroupsAndTypes[group,:] = tempType
  end

end
