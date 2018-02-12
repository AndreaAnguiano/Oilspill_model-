using DataFrames
function oilSpillDataMultiple(FileName::String; depth::Array{Int64,1}=[1,1000], perc::Array{Float64,1}=[1.0], barrellsPerParticle::Int64=1000, rows::Int64 =8)
  File = readtable(FileName, header = false,  separator = ',')
  dataRows = convert(Int64,length(File)/rows)
  ArraySpillByDay = Array{OilSpillDataMultiple}(length(File[1])*dataRows)

   if length(depth) != length(perc)+1
     println("Error")
   end
   if sum(perc) > 1
     println("Error")
   end
   row = 0
   spilltempidx = 0
   for datarow in range(1, dataRows)
     for idx in range(1,length(File[1]))
        subSup = File[idx,row+5]
        barrells = [File[idx,row+4]]
        for barrSub in subSup
          push!(barrells, barrSub)
        end
        day = File[idx,row+2]
        month = File[idx,row+1]
        year = File[idx,row+3]
        date = DateTime(year,month,day)
        depth = [File[idx, row+6]]
        lat = [File[idx, row+7]]
        lon = [File[idx, row+8]]
        spilltemp = OilSpillDataMultiple(date, barrells, depth, lat, lon, barrellsPerParticle)
        spilltempidx  = spilltempidx + 1
        ArraySpillByDay[spilltempidx] = spilltemp
    end

    row = row + rows
  end
  return(ArraySpillByDay)
end
