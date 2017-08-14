using GeometricalPredicates

function particlesByLocation(particles::Array{Particle,1}, positions::Array{Float64,2}, ratio::Float64)
  particlesByPosition = zeros(size(positions)[1])
  allPositionsAndTypes = Array{Array{Int64,1},1}(size(positions)[1])

  for position in 1:size(positions)[1]
    tempParticlesIndx = find(x-> sqrt.((x.lat[end]-positions[position, :][1])^2+(x.lon[end]-positions[position, :][2])^2)< ratio, particles)
    tempParticles = particles[tempParticlesIndx]

    particlesByPosition[position] = length(tempParticles)

    allTypes = Array{Int64}(length(tempParticles))
    for particle in 1:length(tempParticles)
      allTypes[particle] = particles[particle].component
    end
    Types = unique(allTypes)
    TypesAll =[length(find(x -> x == Types[types], allTypes)) for types in 1:length(Types)]
    allPositionsAndTypes[position] = TypesAll

  end



end
