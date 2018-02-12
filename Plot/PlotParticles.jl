using Plots
using MAT
pyplot()
path = "/home/andrea/Data/Datos/"

function plotParticles2D(x::Array{Float64,1},y::Array{Float64,1})
  plot!(x,y, seriestype=:scatter, markersize = 0.7 , legend = false, color= :blue, markerstrokecolor = :blue, xlabel = "Longitud", ylabel= "Latitud")
  gui()
end
function plotParticles3D(x::Array{Float64,1},y::Array{Float64,1},z::Array{Float64,1})
  scatter(x,y,z, color = :blue)
end
function plotGulf(lims::Array{Int64,2})
  Data  = matread(path*"linea_costa_divpol.mat")
  gulf = Data["linea_costa"]
  plot(gulf[:,1], gulf[:,2], color = :black, linewidth = 1, ylims=(lims[2,1], lims[2,2]), xlims=(lims[1,1], lims[1,2]), aspect_ratio=:equal, legend = false)
  gui()
end
function plotByGroup(Groups::Array{String,1}, GroupsAll::Array{Int64,1})
  plot(Groups, GroupsAll, xlabel = "Status", ylabel = "Particles", title= "Particles by status",
  ylims= maximum(GroupsAll)+2000, legend=false,seriestype = :bar, tickfont=12)
end
function plotByType(Types::Array{String,1}, TypesAll::Array{Int64,1})
  plot(Types, TypesAll, xlabel = "Type of oil", ylabel = "Particles", title= "Particles by oil type",
  ylims= maximum(TypesAll)+200, legend=false,seriestype = :bar, tickfont=12)
end

function plotByGroupAndType(Groups::Array{String,1}, GroupsAndTypes::Array{Int64,2}, label::Array{String,2})
  plot(Groups, GroupsAndTypes, legend= true, color_palette= :PuBu, xlabel= "Status", ylabel = "Particles",
   title = "Particles by status and oil type", label = label, ylims= maximum(GroupsAndTypes)+10, seriestype = :bar, tickfont=12)
end

function plotByTypeAndDate(Types::Array{String,1}, TypesAndDates::Array{Float64,1} )
  plot(Types, TypesAndDates, tickfont = 12, xlabel = "Type of oil", ylabel = "Average life(days)", title= "Average life by oil type", legend=false, seriestype = :bar, tickfont=12)
end

function plotByPosition(position::Array{String,1}, particles::Array{Float64,1})
  plot(position, particles, xlabel = "Positions", ylabel = "Particles", title= "Particles by position",
  legend=false, seriestype = :bar, tickfont=12)
end

function plotByPositionAndType(PositionStr::Array{String,1},Types::Array{String,1}, TypesAll::Array{Array{Int64,1},1})
  titles = Array{String,2}(1,length(TypesAll))
  xlab = Array{String,2}(1,length(TypesAll))
  ylab = Array{String,2}(1,length(TypesAll))
  for position in range(1, length(TypesAll))
    titles[position] = "Particles by oil type in position $position"
    xlab[position] = "Type of oil"
    ylab[position] = "Particles"
  end

  plot(Types, TypesAll,layout= length(TypesAll),seriestype = :bar, xlabel= xlab, ylabel = ylab, title = titles, legend = false, tickfont=12)
end
