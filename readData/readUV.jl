path = "/media/petroleo/Datos/"
#-------- function ------
using NetCDF
function readUV(deltaT,currHour, currDay, VF, modelConfig)
  fixedWindDeltaT = 6
  newDay = currDay + 1
  windFileNum = convert(Int64,floor(currHour/fixedWindDeltaT)+ 1)
  windFileNum2 = convert(Int64,ceil((currHour+0.1)/fixedWindDeltaT)+ 1)
  atmFilePrefix = "Dia_" #File prefix for the atmospheric netcdf files
  oceanFilePrefix = "archv.2010_" #File prefix for the ocean netcdf files
  readOceanFile = "$(oceanFilePrefix)$(currDay)_00_3z.nc"
  readOceanFileT2 = "$(oceanFilePrefix)$(newDay)_00_3z.nc"
  readAtmFile = "$(atmFilePrefix)$(currDay)_"
  readAtmFileT2 = "$(atmFilePrefix)$(newDay)_"
  mDepths = copy(modelConfig.depths)

#--------------- currents --------------------
  if currHour == 0 #First time on iteration
    if VF.currDay == currDay

      #read lat, lon and depth from files and create meshgrids for currents and wind
      lat = ncread(path*readOceanFile, "Latitude")
      lon = ncread(path*readOceanFile, "Longitude")
      depths = ncread(path*readOceanFile, "Depth")

      VF.lat = lat
      VF.lon = lon
      VF.depths = depths

      #Setting the minimum and maximum indexes for the depths of the particles

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
      end

      U = ncread(path*readOceanFile, "U", [1,1, VF.depthsMinMax[1]],[-1, -1, VF.depthsMinMax[2]])
      V = ncread(path*readOceanFile,"V",[1,1, VF.depthsMinMax[1]],[-1, -1, VF.depthsMinMax[2]])
      UT2 = ncread(path*readOceanFileT2,"U",[1,1,VF.depthsMinMax[1]],[-1, -1, VF.depthsMinMax[2]])
      VT2 = ncread(path*readOceanFileT2,"V",[1,1,VF.depthsMinMax[1]],[-1, -1, VF.depthsMinMax[2]])
      VF.U = U
      VF.V = V
      VF.UT2 = UT2
      VF.VT2 = VT2


    else   #read new data
      VF.U = VF.UT2
      VF.V = VF.VT2
      UT2 = ncread(path*readOceanFileT2, "U", [1, 1, VF.depthsMinMax[1]],[-1, -1, VF.depthsMinMax[2]])
      VT2 = ncread(path*readOceanFileT2, "V", [1, 1, VF.depthsMinMax[1]], [-1, -1, VF.depthsMinMax[2]])
      VF.UT2 = UT2
      VF.VT2 = VT2
    end
  end

  #---------------------------- winds --------------------------------------
  if currHour == 0 && VF.currDay == currDay #First time on iteration
    UW = ncread(path*readAtmFile*"$windFileNum.nc", "U_Viento")
    VW = ncread(path*readAtmFile*"$windFileNum.nc", "V_Viento")
    UWT2 = ncread(path*readAtmFile*"$windFileNum2.nc","U_Viento")
    VWT2 = ncread(path*readAtmFile*"$windFileNum2.nc", "V_Viento")
    UWR, VWR = rotangle(UW' , VW')
    UWR = flipdim(UWR, 2)
    VWR = flipdim(UWR, 2)
    UWRT2, VWRT2 = rotangle(UWT2', VWT2')
    UWRT2 = flipdim(UWRT2, 2)
    VWRT2 = flipdim(VWRT2, 2)
    VF.UW = UW
    VF.VW = VW
    VF.UWR = UWR
    VF.VWR = VWR
    VF.UWT2 = UWT2
    VF.VWT2 = VWT2
    VF.UWRT2 = UWRT2
    VF.VWRT2 = VWRT2
  else
    #Verify the next time step for the wind is still this day and the file is the same
    if floor(currHour/fixedWindDeltaT) != floor(VF.currHour/fixedWindDeltaT)
      if windFileNum2 > (24/fixedWindDeltaT)
        VF.UW = VF.UWT2
        VF.VW = VF.VWT2
        VF.UWR = VF.UWRT2
        VF.VWR = VF.VWRT2
        UWT2 = ncread(path*readAtmFileT2*"1.nc","U_Viento")
        VWT2 = ncread(path*readAtmFileT2*"1.nc", "V_Viento")
        UWRT2, VWRT2 = rotangle(UWT2',VWT2')
        UWRT2 = flipdim(UWRT2, 2)
        VWRT2 = flipdim(VWRT2, 2)
        VF.UWT2 = UWT2
        VF.VWT2 = VWT2
        VF.UWRT2 = UWRT2
        VF.VWRT2 = VWRT2

      else
        VF.UW = VF.UWT2
        VF.VW = VF.VWT2
        VF.UWR = VF.UWRT2
        VF.VWR = VF.VWRT2
        UWT2 = ncread(path*readAtmFile*"$windFileNum2.nc","U_Viento")
        VWT2 = ncread(path*readAtmFile*"$windFileNum2.nc", "V_Viento")
        UWRT2, VWRT2 = rotangle(UWT2',VWT2')
        UWRT2 = flipdim(UWRT2, 2)
        VWRT2 = flipdim(VWRT2, 2)
        VF.UWT2 = UWT2
        VF.VWT2 = VWT2
        VF.UWRT2 = UWRT2
        VF.VWRT2 = VWRT2
      end
    end
  end
  VF.currDay = currDay
  VF.currHour = currHour

  return VF
end
