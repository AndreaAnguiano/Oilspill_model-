
using NetCDF
function vectorFieldsADCIRC(deltaT::Int64, currHour::Int64, currDay::Int64, VF::VectorFieldsADCIRC, modelConfig::modelConfig, atmFilePrefix::String, oceanFilePrefix::String, uvar::String, vvar::String)
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
      # ele has the elements from the FORT.14 mesh
      ele = ncread(path*readOceanFile, "element")
      # Since ADCIRC 2D has only surface velocities, we create a zero vector for depths
      depths = zeros(1,1)

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

      #We cannot make a lat/lon meshgrid with the nonstructured mesh, so instead we generate vectors for each element
      VF.lon = lon
      VF.lat = lat
      VF.ELE = ele'
      #Read the coast nodes to check if particles are inside the domain
      Costaf = readdlm(path*"costa.txt")
      Costa = [convert(Int64, i) for i in Costaf]
      VF.CostaX = VF.lon[Costa]
      VF.CostaY = VF.lat[Costa]
      Costa = 0
      P = hcat(VF. lon, VF.lat)
      TR = triang(VF, P)
      z = hcat(zeros(length(VF.lon)), zeros(length(VF.lat)))
      VF.MeshInterp = hcat(VF.lon, VF.lat)
      #VF.MeshInterp = interpTRI1init(VF.lon, VF.lat, z)

      U = ncread(path*readOceanFile,uvar , [1,1],[-1, 1])
      V = ncread(path*readOceanFile,vvar,[1,1],[-1, 1])
      UT2 = ncread(path*readOceanFileT2,uvar,[1,1],[-1, 1])
      VT2 = ncread(path*readOceanFileT2,vvar,[1,1],[-1, 1])
      VF.U = U
      VF.V = V
      VF.UT2 = UT2
      VF.VT2 = VT2


    else   #read new data
      VF.U = VF.UT2
      VF.V = VF.VT2
      UT2 = ncread(path*readOceanFileT2, uvar, [1, 1],[-1, -1])
      VT2 = ncread(path*readOceanFileT2, vvar, [1, 1], [-1, 1])
      VF.UT2 = UT2
      VF.VT2 = VT2
    end

    #---------------------------------- winds ---------------------------------------------
    if currHour == 0 && VF.currDay == currDay #First time on iteration
      UW = ncread(path*readAtmFile*"$windFileNum.nc", "windx")
      VW = ncread(path*readAtmFile*"$windFileNum.nc", "windy")
      UWT2 = ncread(path*readAtmFile*"$windFileNum2.nc","windx")
      VWT2 = ncread(path*readAtmFile*"$windFileNum2.nc", "windy")
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
          UWT2 = ncread(path*readAtmFileT2*"1.nc","windx")
          VWT2 = ncread(path*readAtmFileT2*"1.nc", "windy")
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
          UWT2 = ncread(path*readAtmFile*"$windFileNum2.nc","windx")
          VWT2 = ncread(path*readAtmFile*"$windFileNum2.nc", "windy")
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
end
