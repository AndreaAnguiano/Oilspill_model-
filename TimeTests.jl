function main(Days, barrellsPerParticle)
    ## Initialize variable for specific run Days = 3
    startDate = DateTime(2010,04,22)
    endDate =startDate + Dates.Day(Days)
    depths = [0, 400,1000]
    components = [0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.3; 0.0 0.0 0.0 0.1 0.1 0.1 0.2 0.5; 0.0 0.0 0.0 0.0 0.0 0.1 0.2 0.7; ]
    subSurfaceFraction = [1/3, 1/3, 1/3]
    initPartSize = 10
    totComponents = 8
    windContrib = 0.035
    turbulentDiff = 0.2
    diffusion = 0.005
    evaporate = [1]
    biodeg = [1]
    burned = [1]
    collected = [1]
    timeStep = 6
    byComponent = threshold(95,[4, 8, 12, 16, 20, 24, 28, 32], timeStep)

    ArrVF1 = zeros(3)
    ArrVF3 = zeros(3,3,3) # Initial array for vectorFields 3x3
    ArrVF2 = zeros(3,2) # Initial array for vectorFields 3x2
    ArrIntVF2 = ones(Int64,1,1)
    ArrIntVF1 = ones(Int64,1)
    ArrDepthIndx = zeros(length(depths),2)
    ArrTR = GeometricalPredicates.UnOrientedTriangle{Point2D}[]
    #startJulianDate = toJulianDate(startDate)
    #endJulianDate = toJulianDate(endDate)
    decay = Decay(burned,collected, evaporate, biodeg, byComponent)
    lat = [28.0]
    lon = [-88.0]
    # bbox = [-92, 25, -80, 31]
    bbox = [-94, 23, -78, 33]
    # bbox = [-180, -90, -180, 90]

    visualize = false
    # visualize = true
    model = "hycom"
    VF3D =  false
    positions = [[28, -88], [20, -95]]
    spillType = "oil"
    Statistics = false

    configPath = "./ConfigurationFiles/"
    dataPath = "/home/olmozavala/Desktop/PETROLEO_OUT/"

    lims = [-97 -80; 20 31]
    # lims = bbox
    if spillType == "simple" #multiple oil spills
      FileName = string(configPath,"/ndatos_derrame.csv")
      lims = [-98 -80; 18 31]
    else #one oil spill from Oil Budget Calculator (2010)
      FileName = string(configPath,"/spill_data.csv")
    end

    modelConfigs = modelConfig(startDate,endDate, depths, components, subSurfaceFraction, decay, timeStep, initPartSize, totComponents, windContrib, turbulentDiff, diffusion, model, spillType,bbox)
    particles = oilSpillModel(dataPath, configPath, modelConfigs, FileName, ArrVF3, ArrVF2, ArrVF1,ArrIntVF2,ArrIntVF1,ArrTR, ArrDepthIndx, startDate, endDate, visualize, timeStep, lat, lon, VF3D, positions, barrellsPerParticle, lims, Statistics)
    println("Final number of particles:", size(particles))


    if Statistics
      modelStatistics(particles,[28.0 -88.0; 38.0 -88.0; 37.8 -88], 10.0 )
    end
    #particlesByLocation(particles,[28.0 -88.0; 38.0 -88.0; 37.8 -88], 10.0 )
    #particlesByTypeAndDate(particles,12)
    # particlesByGroup(particles)
    #print(particles)

    # funciones para guardar posiciones de partículas
    #lat = [i.lat for i in particles]
    #lon = [i.lon for i in particles]
    #writedlm("particleslats$days30.txt", lat)
    #writedlm("particleslons$days.txt", lon)

end #Main

include("IncludeAll.jl")
main(1, 400)
function timeTests()

 # -------- Test 1 -------
 Days = 2
 barrellsPerParticle = 50
 Depths =  [0,100,1000]
 println("Days:", Days,  "   BarrelsPerPart", barrellsPerParticle)
 @time main(Days, barrellsPerParticle)
 # -------- Test 2 -------
 Days = 2
 barrellsPerParticle = 50
 Depths =  [0,99,1001]
 println("Days:", Days,  "   BarrelsPerPart", barrellsPerParticle)
 @time main(Days, barrellsPerParticle)
 # -------- Test 3 -------
 Days = 4
 barrellsPerParticle = 50
 Depths =  [0,100,1000]
 println("Days:", Days,  "   BarrelsPerPart", barrellsPerParticle)
 @time main(Days, barrellsPerParticle)
# -------- Test 4 -------
 Days = 4
 barrellsPerParticle = 50
 Depths =  [0,99,1001]
 println("Days:", Days,  "   BarrelsPerPart", barrellsPerParticle)
 @time main(Days, barrellsPerParticle)
# -------- Test 5 -------
  Days = 7
  barrellsPerParticle = 10
  Depths =  [0,100,1000]
  println("Days:", Days,  "   BarrelsPerPart", barrellsPerParticle)
  @time main(Days, barrellsPerParticle)
# -------- Test 6 -------
  Days = 7
  barrellsPerParticle = 10
  Depths =  [0,99,1001]
  println("Days:", Days,  "   BarrelsPerPart", barrellsPerParticle)
  @time main(Days, barrellsPerParticle)

end # timeTests
timeTests()

# println("*************************************************")
# using ProfileView
# PROFILEVIEW_USEGTCK = true
# include("IncludeAll.jl")
# @time main(1, 400)
# @time main(3, 40)
# Profile.clear_malloc_data()
# main(2, 40)
# ProfileView.closeall()
# Profile.clear()
# @profile main(3, 40)
# Profile.print(format=:flat)
# ProfileView.view()
