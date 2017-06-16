path = "/media/petroleo/Datos/"
#-------- function ------
using NetCDF
function readUV(deltaT,currHour, currDay, VF, modelConfig, atmFilePrefix, oceanFilePrefix)
  windFileNum = floor(currHour/fixedWindDeltaT)+1
  windFileNum2 = ceil((modelHour + eps)/fixedWindDeltaT)+1
  currDay = -1
  newDay = currDay + 1
  readWind = false
  readWindT2 = false
  readOcean = false
  readOceanT2 = false
  readNextDayWind = false

  readOceanFile = "$(oceanFilePrefix)$(currDay)_00_3z.nc"
  readOceanFileT2 = "$(oceanFilePrefix)$(newDay)_00_3z.nc"


  if modelHour == 0 && currDay == -1
    readWind = true
    readWindT2 = true
    readOcean = true
    readOceanT2 = true

    lat = ncread(path*readOceanFile, "Latitude")
    lon = ncread(path*readOceanFile, "Longitude")
    depths = ncread(path*readOceanFile, "Depth")

    VF.lat = lat
    VF.lon = lon
    VF.depths = depths

    # Setting the minimum and maximum indexes for the depths of the particles
    #Setting the minimum index
    val = (minimum(abs(VF.depths - mDepths[1])))
    indx = find(obj -> obj == val, VF.depths)[1]
    if val == 0
      VF.depthsMinMax[1] = indx
    else
      #Verify we are on the right side of the closest depth
      if VF.depths[indx] - mDepths[1] < 0
        VF.depthsMinMax[1] = indx
      else
        VF.depthsMinMax[1] = max(indx-1, 0)
      end
    end

    #Setting the maximum index
    val = (minimum(abs(VF.depths - mDepths[end])))
    indx = find(obj -> obj == val, VF.depths)[1]

    if val == 0
      VF.depthsMinMax[2] = indx
    else
      #Verify we are on the right side of the closest depth
      if VF.depths[indx] - mDepths[1] < 0
        VF.depthsMinMax[2] = indx
      else
        VF.depthsMinMax[2] = min(indx-1, length(VF.depths))
      end
    end
    #Assigning the closest indexes for each depth
    currIndx = 1
    for currDepth = mDepths
      val = (minimum(abs(VF.depths - currDepth)))
      indx = find(obj -> obj == val, VF.depths)[1]

      if val == 0
        #For this depth we only need one index, because is the exact depth
        VF.depthsIndx[currIndx, :] = [indx, indx]
      else
        #Verify we are on the right side of the closest depth
        if (VF.depths[indx] - currDepth) > 0
          VF.depthsIndx[currIndx, :] = [max(indx-1, 0), indx]
        else
          VF.depthsIndx[currIndx, :] = [indx, min(indx+1, VF.depthsMinMax[2])]
        end
      end
      currIndx = currIndx + 1

    if floor(modelHour/fixedWindDeltaT)~= floor(obj.currHour/fixedWindDeltaT)
      readWindT2 = true
    end

    if windFileT2Num > (24/fixedWindDeltaT) && currHour%fixedWindDeltaT == 0
      readNextDayWind = true
      readWindT2 = true
    end

    if modelDay ~= currDay
      readOceanT2 = true
      VF.U = VF.UT2
      VF.V = VF.VT2
    end

  end

  if readNextDayWind
    readWindFileT2 = "$(atmFilePrefix)$(currDay + 1)_.nc"
    VF.UW = VF.UWT2
    VF.VW = VF.VWT2
    VF.UWR = VF.UWRT2
    VF.VWR = VF.VWRT2

  else
    readWindFileT2 = "$(atmFilePrefix)$(currDay)_"
