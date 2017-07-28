using NetCDF
function VectorFields2(deltaT,currHour, currDay, VF, modelConfig, atmFilePrefix, oceanFilePrefix)
  path = "/media/petroleo/Datos/"
  windDeltaT = 6
  myEps = .01
  currDay = toJulianDate(currDay)
  newDay = currDay + 1
  #---------------------- read UV -------------------------------

  windFileNum = floor(currHour/windDeltaT)+1
  windFileNum2 = ceil((currHour + myEps)/windDeltaT)+1

  #These variables indicates if we have to read new files
  firstRead = false
  readWindT2 = false
  readOceanT2 = false
  readNextDayWind = false

  #Create the file names
  readOceanFile = "$(oceanFilePrefix)$(currDay)_00_3z.nc"
  readOceanFileT2 = "$(oceanFilePrefix)$(newDay)_00_3z.nc"
  readWindFile = "$(atmFilePrefix)$(currDay)_$(Int64(windFileNum)).nc"

 #----- only executed the first time of the model, reads, lat, lon depths and computes depth indexes

  if  currHour == 0 && VF.currDay == currDay
    #on the first day we read wind and currents
    firstRead = true
    readWindT2 = true
    readOceanT2 = true
    #Read lat, lon and depth from files
    lat = ncread(path*readOceanFile, "Latitude")
    lon = ncread(path*readOceanFile, "Longitude")
    depths = ncread(path*readOceanFile, "Depth")
    VF.lat = lat
    VF.lon = lon
    VF.depths = depths
    #Setting the minimum and maximum indexes for the depths of the particles
    # ------------------- depth indexes -----------------------------------
    idx = 1
    for currDepth = modelConfig.depths
      floorIdx = findlast(obj -> obj <= currDepth, VF.depths)
      ceilIdx = findfirst(obj -> obj >= currDepth, VF.depths)
      #These are the index
      VF.depthsIndx[idx, :] = [floorIdx, ceilIdx]

      #These will be the relative indexes, these are the ones used by advectparticles
      if floorIdx == ceilIdx
         VF.depthsRelativeIndx[idx, :] = [idx, idx]
      else
        VF.depthsRelativeIndx[idx, :] = [idx, idx+1]
      end
      idx = idx + 1
    end
    #Used to read the files min and max depth values

    VF.depthsMinMax = [findfirst(obj -> obj >= modelConfig.depths[1], VF.depths), findfirst(obj -> obj >= modelConfig.depths[end], VF.depths)]

  else
  # ------ this we check every other time that is not the first time -------------------
    #verify we haven't increase the file name

    if floor(currHour/windDeltaT) != floor(currHour/windDeltaT)
      readWindT2 = true
    end

    #verify the next time step for the wind is still in this day
    if windFileNum2 > (24/windDeltaT) && readWindT2
      readNextDayWind = true
    end
    if currDay != VF.currDay
      readOceanT2 = true
    end
  end
  if readNextDayWind
    readWindFileT2 = "$(atmFilePrefix)$(newDay)_1.nc"
  else
    readWindFileT2 = "$(atmFilePrefix)$(currDay)_$(Int64(windFileNum2)).nc"

  end

  #----------------- reading data -------------------------
  #verify if we need to read the winds and currents for the current day
  if firstRead
    #reading currents for current day
    T1 = ncread(path*readOceanFile, "U", [1, 1, VF.depthsMinMax[1]], [-1,-1, VF.depthsMinMax[2]])
    T2 = ncread(path*readOceanFile, "V", [1, 1, VF.depthsMinMax[1]], [-1,-1, VF.depthsMinMax[2]])
    #Cut U and V to the only depth levels that we are going to use
    VF.UD = flipdim(rotr903D(T1[:,:,unique(VF.depthsIndx)],1),3)
    VF.VD = flipdim(rotr903D(T2[:,:,unique(VF.depthsIndx)],1),3)
    #reading winds for current day

end
