using Plots
plotlyjs()

function modelStatistics(particles::Array{Particle,1}, positions::Array{Float64,2},ratio::Float64)
  particlesByLocation(particles, positions,ratio)

  particlesByTypeAndDate(particles)

  particlesByGroup(particles)

end
