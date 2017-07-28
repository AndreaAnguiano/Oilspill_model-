using Plots
plotly()
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

  for group in 1:length(Groups)
    indxStatus = find(x-> x.status == Groups[group], particles)
    subPart = particles[indxStatus]
      for typ in 1:length(Types)
        indxComp = find(x-> x.component == Types[typ], particles)
        GroupsAndTypes[group,typ] = length(indxComp)
      end
  end

  newGroupsAndTypes = Array{Int64,1}[]
  for group in 1:length(GroupsAndTypes[:,1])
    push!(newGroupsAndTypes, GroupsAndTypes[group,:])
  end


  println(Groups)
  trace1 = ["x" => Groups, "y" => newGroupsAndTypes, "name" => "Types", "type" => "bar"]
  data = trace1
  plot(data)

end
