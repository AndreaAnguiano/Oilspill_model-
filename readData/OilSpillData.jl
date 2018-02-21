using DataFrames
using CSV
function oilSpillData(FileName::String, lat::Array{Float64,1}, lon::Array{Float64,1}; depth::Array{Int64,1}=[1,1000], perc::Array{Float64,1}=[1.0], barrellsPerParticle::Float64=1000.0)
  File = CSV.read(FileName,  delim = ';')
  ArraySpillByDay = Array{OilSpillData}(length(File[1]))

  if length(depth) != length(perc)+1
    println("Error")
  end
  if sum(perc) > 1
    println("Error")
  end

  dates = [DateTime(File[i,3],File[i,1], File[i,2]) for i in range(1,length(File[1]))]
  barrells = [File[i,4] for i in range(1,length(File[1]))]
  inLandRecovery = [File[i,5] for i in range(1,length(File[1]))]
  burned = [File[i,6] for i in range(1,length(File[1]))]
  RITT_TopHat =[File[i,7] for i in range(1,length(File[1]))] #collected from well
  collected = [File[i,8] for i in range(1,length(File[1]))] #oilyWater, collected from sea
  subsurfDispersants = [File[i,9] for i in range(1,length(File[1]))]
  surfaceDispersants = [File[i,10] for i in range(1,length(File[1]))]
  evaporated = zeros(length(dates))

  #constants
  k1 = 0.20   #Natural dispersion (subsurface)
  k2 = 4/9   # Chemical dispersion (subsurface)
  k3 = 0.05  # Chemical dispersion (surface)
  k4 = 0.33  # First day evaporation
  k5 = 0.04  # Second day evaporation
  k6 = 0.20  # Net oil fraction in skimmed oil
  k7 = 0.075 # Dissolution of dispersed oil
  k8 = 0.05  # Natural dispesion (surface)
  abarrels  = 42 # There are 42 gallons in one barrel
  zeros_vec = zeros(length(ArraySpillByDay),1)

  #Equations according to Oil Budget Calculator (2010)
  #Effective discharge (VRE)
  EffectiveDischarge = barrells - RITT_TopHat
  negativeIndx = find(obj -> obj < 0, EffectiveDischarge)
  EffectiveDischarge[negativeIndx] = 0
  #Subsurface chemical dispersion (VDC)
  VCB = subsurfDispersants/abarrels
  X = 90*VCB
  subSurfChemDispr = (1 - k7) * minimum([X*k2 EffectiveDischarge],2)
  #Subsurface natural dispersion (VDN)
  Y = EffectiveDischarge - subSurfChemDispr./(1 - k7)
  subSurfNatrDispr = (1 - k7) * maximum([zeros_vec k1*Y],2)
  #Subsurface total dispersion (VDB)
  subSurfTotlDispr = subSurfChemDispr + subSurfNatrDispr
  # Skimmed oil as a fraction of oily water (VNW)
  skimmedOil = collected * k6
  #surface oil
  surfaceOil = EffectiveDischarge - subSurfTotlDispr
  #surface oil accumulated
  surfaceAccum = cumsum(surfaceOil)
  # Z (t)
  Z = EffectiveDischarge - subSurfTotlDispr/(1-k7)
  #Z (t - 1)
  Zprev =  [0;Z[1:end-1]]
  #Burned (t - 1)
  burnedPrev = [0;burned[1:end-1]]
  #W(t-1)
  Wprev = (1 - k4) * Zprev - burnedPrev
  negativeIndx = find(obj -> obj < 0, Wprev)
  Wprev[negativeIndx] = 0
  #W(t)
  W = maximum([zeros_vec (1 - k4)*Z-burned],2)
  #Oil evaporated or dissolved (VE)
  evaporated = k4 * Z + k5 * Wprev + k7 * subSurfTotlDispr/(1 - k7)
  #Surface natural dispersion (VNS)
  surfaceNatrDispr = maximum([zeros_vec k8 * W], 2)
  #surface chemical dispersants at day t (VCS)
  VCS = surfaceDispersants/abarrels
  #other oil (VSD)
  otherOil = EffectiveDischarge - (evaporated + skimmedOil + burned + subSurfTotlDispr + surfaceNatrDispr)
  # VS (t)
  VS = cumsum(otherOil)
  negativeIndx = find(obj -> obj < 0, VS)
  VS[negativeIndx] = 0
  #VS(t - 1)
  VSprev = [0; VS[1:end-1]]
  #surface chemical dispersion (VDS)
  surfaceChemDispr = minimum([20*k3*VCS VSprev],2)
  #surface degradation
  surfDeg = evaporated + skimmedOil + burned + surfaceNatrDispr + surfaceChemDispr
  #surface degradation accumulated
  surfDegAccum = cumsum(surfDeg)
  #oil in surface water
  surfWater = surfaceAccum - surfDegAccum

  # for i in range(1,length(dates))
    # println(typeof(barrells[i]))
    # println(typeof(inLandRecovery[i]))
    # println(typeof(evaporated[i]))
    # println(typeof(burned[i]))
    # println(typeof(collected[i]))
    # println(typeof(subsurfDispersants[i]))
    # println(typeof(surfaceDispersants[i]))
  # end

  ArraySpillByDay = [OilSpillData(dates[i],[barrells[i]],inLandRecovery[i],evaporated[i],burned[i],collected[i], subsurfDispersants[i],
                        surfaceDispersants[i], depth, barrellsPerParticle,lat, lon) for i in range(1,length(dates))]

  #Barrells to particles

  return(ArraySpillByDay)

end
