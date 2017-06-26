
using NetCDF
function vectorFieldsADCIRC(deltaT, currHour, currDay, VF, modelConfig, atmFilePrefix, oceanFilePrefix, uvar, vvar)
  path = "/media/petroleo/DatosADCIRC/"
  currentDeltaT = 1
  myEps = 0.01
  newDay = currDay + 1

  windFileNum = convert(Int64,floor(currHour/currentDeltaT)+ 1)
  windFileNum2 = convert(Int64,ceil((currHour + myEps)/currentDeltaT)+ 1)

  oceanFileNum = convert(Int64,floor(currHour/currentDeltaT)+ 1)
  oceanFileNum2 = convert(Int64,ceil((currHour + myEps)/currentDeltaT)+ 1)

  #Create the file names
  readOceanFile = "$(oceanFilePrefix)$(currDay).nc"
  readOceanFileT2 = "$(oceanFilePrefix)$(newDay).nc"
  readAtmFile = "$(atmFilePrefix)$(currDay)_"
  readAtmFileT2 = "$(atmFilePrefix)$(newDay)_"


  mDepths = copy(modelConfig.depths)

  if currHour == 0 #First time on iteration
    if VF.currDay == currDay

      #read lat, lon and depth from files and create meshgrids for currents and wind

      lat = ncread(path*readOceanFile, "y")
      lon = ncread(path*readOceanFile, "x")
      depths = ncread(path*readOceanFile, "depth")

      VF.lat = lat
      VF.lon = lon
      VF.depths = depths

      #Setting the minimum and maximum indexes for the depths of the particles

      idx = 1
      for currDepth = mDepths
        floorIdx = findlast(obj -> obj <= currDepth, VF.depths)
        ceilIdx = findfirst(obj -> obj >= currDepth, VF.depths)

        #These are the index
        VF.depthsIndx[idx, :] = [floorIdx, ceilIdx]
        idx = idx + 1
      end


      VF.depthsMinMax = [findfirst(obj -> obj >= modelConfig.depths[1], VF.depths), findfirst(obj -> obj >= modelConfig.depths[end], VF.depths)]
    end
  end
end
