using Interpolations
function interpTRI1init(lon::Array{Float64,1}, lat::Array{Float64,1}, Uin::Array{Float64,2})
  return interpolate((lon, lat), Uin, Gridded(Constant()))
end
