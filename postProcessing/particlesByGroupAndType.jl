using Plots
pyplot()
#grupo en el caso del petroleo son evaporadas, quemadas, etc. Y tipo, son los componentes del petroleo.

function particlesByGroup(particles::Array{Particle,1})

  allGroups = Array{String}(length(particles))

  for particle in 1:length(particles)
    allGroups[particle] = particles[particle].status
  end
  Groups = unique(allGroups)
  totGroups = Array{Int64}(length(Groups))

  for group in 1:length(Groups)
    totGroups[group] = length(find(x -> x == Groups[group], allGroups))
  end


  println(allGroups)

end
