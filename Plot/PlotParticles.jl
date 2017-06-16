using PyCall
pygui(:qt)

using PyPlot
function plotParticles(lon, lat, depth)
  ax = axes()
  grid("on")
  scatter3D(lon, lat, depth)

end
