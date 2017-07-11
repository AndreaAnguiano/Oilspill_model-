using NetCDF
function VectorFields2(deltaT,currHour, currDay, VF, modelConfig, atmFilePrefix, oceanFilePrefix)
  path = "/media/petroleo/Datos/"
  windDeltaT = 6
  myEps = .01
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

    TempUW = ncread(path*readWindFile, "U_Viento")
    TempVW = ncread(path*readWindFile, "V_Viento")
    VF.UWRD, VF.VWRD = rotangle(TempUW', TempVW')
  end
  #Verify if we need to read the winds for the next day
  if readWindT2
    if !firstRead
      VF.UWRD = VF.UWRDT2
      VF.VWRD = VF.VWRDT2
    end
    TempUW = ncread(path*readWindFileT2, "U_Viento")
    TempVW = ncread(path*readWindFileT2, "V_Viento")
    #Obtain the next rotated winds
    VF.UWRDT2, VF.VWRDT2 = rotangle(TempUW',TempVW')

    #Update the temporal variable that holds U(d_1) - U(d_0) used for the interpolation

    VF.UWRDT2minusUWRDT = VF.UWRDT2 - VF.UWRD
    VF.VWRDT2minusVWRDT = VF.VWRDT2 - VF.VWRD
  end

  #making the interpolation to the proper 'timesteps'
  if readWindT2
    if firstRead
      #The final U and V (winds) corresponds, in this case to the current timeframe values
      VF.UWR = VF.UWRD
      VF.VWR = VF.VWRD
    else
      #The final U and V (winds) corresponds, in this case, to the previous timeframe values
      VF.UWR = VF.UWRT2
      VF.VWR = VF.VWRT2
    end
    #Interpolate UWT2 correctly, depending on the model hour
    VF.UWRT2 = VF.UWRD + (((currHour%windDeltaT)+ modelConfig.timeStep)/windDeltaT)*VF.UWRDT2minusUWRDT
    VF.VWRT2 = VF.VWRD + (((currHour%windDeltaT)+ modelConfig.timeStep)/windDeltaT)*VF.VWRDT2minusVWRDT
  else
    #The final U and V (winds) corresponds, in this case, to the current timeframe values
    VF.UWR = VF.UWRT2
    VF.VWR = VF.VWRT2
    #Interpolate UWT2 correctly, depending on the model hour
    VF.UWRT2 = VF.UWRD + (((currHour%windDeltaT)+ modelConfig.timeStep)/windDeltaT)*VF.UWRDT2minusUWRDT
    VF.VWRT2 = VF.VWRD + (((currHour%windDeltaT)+ modelConfig.timeStep)/windDeltaT)*VF.VWRDT2minusVWRDT
  end

  #------------------ reading and organizing the currents------------------------------
  if readOceanT2
    T1 = ncread(path*readOceanFileT2, "U",[1, 1, VF.depthsMinMax[1]], [-1,-1, VF.depthsMinMax[2]])
    T2 = ncread(path*readOceanFileT2, "V", [1, 1, VF.depthsMinMax[1]], [-1,-1, VF.depthsMinMax[2]])
    #Cut U and V to the only depth levels that we are going to use
    VF.UDT2 = flipdim(rotr903D(T1[:,:,unique(VF.depthsIndx)],1),3)
    VF.VDT2 = flipdim(rotr903D(T2[:,:,unique(VF.depthsIndx)],1),3)
  end

  #making the interpolation to the proper timesteps
  if currHour == 0
    VF.U = VF.UD
    VF.V = VF.VD
    #Update the temporal variable that holds U(d_1) - U(d_0)
    VF.UDT2minusUDT = VF.UDT2 - VF.UD
    VF.VDT2minusVDT = VF.VDT2 - VF.VD
    #interpolate UT2 correctly, depending on the model hour
    VF.UT2 = VF.UD + ((currHour+modelConfig.timeStep)/24)*VF.UDT2minusUDT
    VF.VT2 = VF.VD + ((currHour+modelConfig.timeStep)/24)*VF.VDT2minusVDT
  else
    VF.U = VF.UT2
    VF.V = VF.VT2
    #Interpolate UT2 and VT2 correctly, depending on the model hour

    VF.UT2 = VF.UD + ((currHour+modelConfig.timeStep)/24)*VF.UDT2minusUDT
    VF.VT2 = VF.VD + ((currHour+modelConfig.timeStep)/24)*VF.VDT2minusVDT
  end

  #Update the current time that has already been executed (read in this case)
  VF.currDay = currDay
  VF.currHour = currHour
end
