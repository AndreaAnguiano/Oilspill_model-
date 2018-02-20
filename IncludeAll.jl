#----Run once ----
# Pkg.add("PyPlot")
# Pkg.add("PlotlyJS")
# Pkg.add("GLVisualize")
# Pkg.add("CSV")
# Pkg.add("Plots")
# Pkg.add("StatPlots")
# Pkg.add("GeometricalPredicates")
# Pkg.add("NetCDF")
# Pkg.add("MAT")
# Pkg.add("DataFrames")
# Pkg.add("ProfileView")
# Pkg.add("Rsvg")
# Pkg.add("Profile")
# using PyPlot
# using Rsvg
#----initial conditions----
 include("model/Types.jl")

 include("Plot/PlotParticles.jl")

 include("postProcessing/modelStatistics.jl")
 include("postProcessing/particlesByGroupAndType.jl")
 include("postProcessing/particlesByLocation.jl")
 include("postProcessing/particlesByTypeAndDate.jl")

 include("processing/advectParticles.jl")
 include("processing/advectParticles2.jl")
 include("processing/advectParticles3D.jl")
 include("processing/advectParticlesADCIRC.jl")
 include("processing/initParticles.jl")
 include("processing/interp.jl")
 include("processing/oilDegradation.jl")
 include("processing/rotangle.jl")
 include("processing/splitByTimeStep.jl")
 include("processing/threshold.jl")

 include("readData/OilSpillData.jl")
 include("readData/OilSpillDataMultiple.jl")
 include("readData/VectorFields.jl")
 include("readData/VectorFields2.jl")
 include("readData/VectorFields3D.jl")
 include("readData/VectorFieldsADCIRC.jl")

 include("tools/Ady.jl")
 include("tools/findTriangle.jl")
 include("tools/rotr903D.jl")
 include("tools/toJulianDate.jl")
 include("tools/Triangulation.jl")
 include("tools/roundStat.jl")

 include("OilSpillModel.jl")

 # include("Visualization/VisualizationExample.jl")
 # include("Visualization/VisualizationExample2.jl")
