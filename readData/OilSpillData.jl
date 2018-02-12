using DataFrames
function oilSpillData(FileName::String, lat::Array{Float64,1}, lon::Array{Float64,1}; depth::Array{Int64,1}=[1,1000], perc::Array{Float64,1}=[1.0], barrellsPerParticle::Int64=1000)
  File = readtable(FileName, header = true,  separator = ';')
  ArraySpillByDay = Array{OilSpillData}(length(File[1]))

  if length(depth) != length(perc)+1
    println("Error")
  end
  if sum(perc) > 1
    println("Error")
  end
  for idx in range(1,length(File[1]))
    subSup = File[idx, 8].*perc
    barrells = [File[idx,4]]
    for barrSub in subSup
      push!(barrells, barrSub)
    end
    day = File[idx,2]
    month = File[idx,1]
    year = File[idx,3]
    date = DateTime(year,month,day)
    burned = File[idx, 5]
    evaporate = File[idx, 6]
    collected = File[idx, 7]
    subsurfDispersants = File[idx, 9]
    surfaceDispersants = File[idx, 10]
    spilltemp = OilSpillData(date,barrells,evaporate,burned,collected, subsurfDispersants, surfaceDispersants, depth, barrellsPerParticle,lat, lon)
    ArraySpillByDay[idx] = spilltemp
  end

  return(ArraySpillByDay)
end
