using Plots
plotlyjs()
function plotParticles(x,y,z)
  scatter3d(x,y,z, xlims = maximum(x), ylims = maximum(y), zlims = maximum(z))
  gui()
end

function plotByGroup(Groups::Array{String,1}, GroupsAll::Array{Int64,1})
  plot(Groups, GroupsAll, xlabel = "Status", ylabel = "Particles", title= "Particles by status",
  ylims= maximum(GroupsAll)+2000, legend=false,seriestype = :bar)
end
function plotByType(Types::Array{String,1}, TypesAll::Array{Int64,1})
  plot(Types, TypesAll, xlabel = "Type of oil", ylabel = "Particles", title= "Particles by oil type",
  ylims= maximum(TypesAll)+200, legend=false,seriestype = :bar)
end

function plotByGroupAndType(Groups::Array{String,1}, GroupsAndTypes::Array{Int64,2}, label::Array{String,2})
  plot(Groups, GroupsAndTypes, legend= true, color_palette= :PuBu, xlabel= "Status", ylabel = "Particles",
   title = "Particles by status and oil type", label = label, ylims= maximum(GroupsAndTypes)+10, seriestype = :bar)
end

function plotByTypeAndDate(Types::Array{String,1}, TypesAndDates::Array{Int64,1} )
  plot(Types, TypeAndDates, xlabel = "Type of oil", ylabel = "Average life", title= "Average life by oil type", legend=false, seriestype = :bar)
end

function plotByPosition(position::Array{String,1}, particles::Array{Float64,1})
  plot(position, particles, xlabel = "Positions", ylabel = "Particles", title= "Particles by position",
  legend=false, seriestype = :bar)
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

  plot(Types, TypesAll,layout= length(TypesAll),seriestype = :bar, xlabel= xlab, ylabel = ylab, title = titles, legend = false)
end
