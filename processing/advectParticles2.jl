using Interpolations
function advectParticles2(VF, modelConfig, Particles, currDate)

  DeltaT = modelConfig.timeStep*3600 #Move DT to seconds
  R = 6371e+03
# Get the index for the live particles
  LiveParticlesIndx = find(obj -> obj.isAlive == true, Particles)

# Get live particles
  LiveParticles = Particles[LiveParticlesIndx]
  numParticles = length(LiveParticles)

  #Get particles last depth
  particleDepth = [obj.depths[end] for obj in LiveParticles]

  # Reading all the positions for live particles
  latP = zeros(numParticles)
  lonP = zeros(numParticles)
  numParticles = length(LiveParticles)

  for idxPart = 1:numParticles
    particle = LiveParticles[idxPart]
    ##Get current particle
    latP[idxPart] = particle.lat[particle.currTimeStep]
    lonP[idxPart] = particle.lon[particle.currTimeStep]
  end

  #Iterate over the different depths
  dIndx = 1

  for depth = modelConfig.depths
    #Get the index for the particles at this depth
    currPartIndex = particleDepth == depth
    originalIndexes = find(currPartIndex)

    #Get the depth indexes for the current particles
    currDepthRelativeIndx = VF.depthsRelativeIndx[dIndx, :]
    currDepthIndx = VF.depthsIndx[dIndx,:]


    #Verify we are in the surface in order to incorporate the wind contribution
    if depth == 0
        U = VF.U[:,:,currDepthRelativeIndx[1]]
        V = VF.V[:,:,currDepthRelativeIndx[1]]

        UT2 = VF.UT2[:,:,currDepthRelativeIndx[1]]
        VT2 = VF.VT2[:,:,currDepthRelativeIndx[1]]

        # Incorporate the force of the wind (using the rotated winds)

        U = U + VF.UWR*modelConfig.windContrib
        V = V + VF.VWR*modelConfig.windContrib

        UT2 = UT2 + VF.UWRT2*modelConfig.windContrib
        VT2 = VT2 + VF.VWRT2*modelConfig.windContrib
    else
        #If we are not in the surface, we need to verify if interpolatation for the proper depth is needed
        if currDepthRelativeIndx[1] == currDepthRelativeIndx[2]
            # In this case the particles are exactly in one depth (no need to interpolate)
            U = VF.U[:,:,currDepthRelativeIndx[1]]
            V = VF.V[:,:,currDepthRelativeIndx[1]]

            UT2 = VF.UT2[:,:,currDepthRelativeIndx[1]]
            VT2 = VF.VT2[:,:,currDepthRelativeIndx[1]]
        else
            # In this case we need to interpolate the currents to the proper Depth
            rangeD = VF.depths[currDepthIndx[2]] - VF.depths[currDepthIndx[1]]
            distance = depth - VF.depths[currDepthIndx[1]]
            toMult = distance/rangeD
            U = VF.U[:,:,currDepthRelativeIndx[1]] + toMult.*(VF.U[:,:,currDepthRelativeIndx[2]] - VF.U[:,:,currDepthRelativeIndx[1]])
            V = VF.V[:,:,currDepthRelativeIndx[1]] + toMult.*(VF.V[:,:,currDepthRelativeIndx[2]] - VF.V[:,:,currDepthRelativeIndx[1]])
            UT2 = VF.U2[:,:,currDepthRelativeIndx[1]] + toMult.*(VF.UT2[:,:,currDepthRelativeIndx[2]] - VF.UT2[:,:,currDepthRelativeIndx[1]])
            VT2 = VF.VT2[:,:,currDepthRelativeIndx[1]] + toMult.*(VF.VT2[:,:,currDepthRelativeIndx[2]] - VF.VT2[:,:,currDepthRelativeIndx[1]])
        end
   end

    #Interpolate the U and V fields for the particles positions

    Uinterp = interpolate((VF.lat, VF.lon), U, Gridded(Linear()))
    Vinterp = interpolate((VF.lat, VF.lon), V, Gridded(Linear()))
    UN = Uinterp[latP,lonP]
    VN = Uinterp[latP,lonP]
    Upart = [UN[i,i] for i in range(1,length(lonP))]
    Vpart = [VN[i,i] for i in range(1, length(lonP))]

    #Move particles to dt/2 (Runge Kutta 2)
    k1lat = (DeltaT*Vpart)*(180/(R*pi))
    k1lon = ((DeltaT*Upart)*(180/(R*pi))).*cosd(latP)

    #Make half the jump
    tempK2lat = latP + k1lat/2
    tempK2lon = lonP + k1lon/2

    #Interpolate VF.U and VF.V to DeltaT/2
    Uhalf = U + (UT2 - U)/2
    Vhalf = V + (VT2 - V)/2

    #Interpolate VF.U and VF.V to New particles positions using VF.U at dt/2
    UhalfInterp = interpolate((VF.lat, VF.lon), Uhalf, Gridded(Linear()))
    VhalfInterp = interpolate((VF.lat, VF.lon), Vhalf, Gridded(Linear()))
    UHN = UhalfInterp[tempK2lat, tempK2lon]
    VHN = VhalfInterp[tempK2lat, tempK2lon]
    UhalfPart = [UHN[i,i] for i in range(1,length(lonP))]
    VhalfPart = [VHN[i,i] for i in range(1,length(lonP))]

    #Add turbulent-diffusion
    Uturb = UhalfPart.*(-modelConfig.turbulentDiff + (2*modelConfig.turbulentDiff).*(rand(size(UhalfPart))))
    Vturb = VhalfPart.*(-modelConfig.turbulentDiff + (2*modelConfig.turbulentDiff).*(rand(size(VhalfPart))))
    UhalfPart = UhalfPart + Uturb
    VhalfPart = VhalfPart + Vturb

    #Move particles to dt
    newLatP = latP + (DeltaT*VhalfPart)*(180/(R*pi))
    newLonP = lonP + ((DeltaT*UhalfPart)*(180/(R*pi))).*cosd(latP)

    #println("NewLatP: ", newLatP)
    #Iterate over the particles and add the new positions
    for idxPart = 1:length(LiveParticles)
    # Get the current particle
      particle = LiveParticles[idxPart]
    #Add in one the current time step of the particle
      particle.currTimeStep = particle.currTimeStep + 1
      push!(particle.lat, newLatP[idxPart])
      push!(particle.lon, newLonP[idxPart])
      #Update the next date
      push!(particle.dates, currDate)
      #println("particle num:", idxPart, " ", particle.lat)
      #Lifetime of the particle in hours
      particle.lifeTime = particle.lifeTime + modelConfig.timeStep
    end
    #Increment the index for the current depth value
    dIndx = dIndx + 1
  end

end