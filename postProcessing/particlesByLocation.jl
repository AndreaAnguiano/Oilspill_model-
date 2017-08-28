using GeometricalPredicates

function particlesByLocation(particles::Array{Particle,1}, positions::Array{Float64,2}, ratio::Float64)
  particlesByPosition = zeros(size(positions)[1])
  allPositionsAndTypes = Array{Array{Int64,1},1}(size(positions)[1])
  allPositionsAndGroups = Array{Array{Int64,1},1}(size(positions)[1])
  allGroupsFinal = Array{Int64,1}[]

  for position in 1:size(positions)[1]
    tempParticlesIndx = find(x-> sqrt.((x.lat[end]-positions[position, :][1])^2+(x.lon[end]-positions[position, :][2])^2)< ratio, particles)
    tempParticles = particles[tempParticlesIndx]

    particlesByPosition[position] = length(tempParticles)

    totTypes = Array{Int64}(length(tempParticles))
    totGroups = Array{String}(length(tempParticles))

    for particle in 1:length(tempParticles)
      totTypes[particle] = particles[particle].component
      totGroups[particle] = particles[particle].status
    end

    Types = unique(totTypes)
    Groups = sort(unique(totGroups))

    allGroups =[length(find(x -> x == Groups[group],totGroups)) for group in 1:length(Groups)]
    allTypes =[length(find(x -> x == Types[types], totTypes)) for types in 1:length(Types)]

    #all types by position (# particles by position)
    allPositionsAndTypes[position] = allTypes
    #all groups by position (#particles by group)
    allPositionsAndGroups[position] = allGroups

    end


  positionsStr = ["Position $x" for x in 1:size(positions)[1]]
  typesString = ["Type 1", "Type 2", "Type 3", "Type 4", "Type 5", "Type 6", "Type 7", "Type 8"]
  label = ["Type 1" "Type 2" "Type 3" "Type 4" "Type 5" "Type 6" "Type 7" "Type 8"]
  plotByPositionAndType(positionsStr, typesString, allPositionsAndTypes)

  plotByPosition(positionsStr, particlesByPosition)




  gui()


end
