using Interpolations
function advectParticles2(VF::vectorFields, modelConfig::modelConfig, Particles::Array{Particle}, currDate)
    DeltaT::Int64 = modelConfig.timeStep*3600 #Move DT to seconds
    R::Int64 = 6371e+03
    # Get the index for the live particles
    LiveParticlesIndx::Array{Int64,1} = find(obj -> obj.isAlive == true, Particles)

    # Get live particles
    LiveParticles::Array{Particle,1} = Particles[LiveParticlesIndx]
    numParticles::Int64 = length(LiveParticles)

    #Get particles last depth
    particleDepth::Array{Float64,1} = [obj.depths[end] for obj in LiveParticles]
    # println(particleDepth)
    # # Reading all the positions for live particles
    latP::Array{Float64,1} = zeros(Float64, numParticles)
    lonP::Array{Float64,1} = zeros(Float64, numParticles)

    #Iterate over the different depths
    dIndx::Int64 = 1

    # Initialize variables
    U = Array{Float64,2}(size(VF.U)[1:2])
    V = Array{Float64,2}(size(VF.U)[1:2])
    UT2 = Array{Float64,2}(size(VF.U)[1:2])
    VT2 = Array{Float64,2}(size(VF.U)[1:2])
    Uhalf = Array{Float64,2}(size(VF.U)[1:2])
    Vhalf = Array{Float64,2}(size(VF.U)[1:2])

    rangeD::Float64 = 0.0
    distance::Float64 = 0.0
    toMult::Float64 = 0.0

    for depth = modelConfig.depths
        # #Get the depth indexes for the current particles
        currDepthRelativeIndx::Array{Int64,1} = VF.depthsRelativeIndx[dIndx, :]
        currDepthIndx::Array{Int64,1}= VF.depthsIndx[dIndx,:]

        particlesDepthIndx::Array{Int64,1} = find(depthIndx -> depthIndx == depth, particleDepth)
        latP = [LiveParticles[idx].lat[end] for idx in particlesDepthIndx]
        lonP = [LiveParticles[idx].lon[end] for idx in particlesDepthIndx]

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

        Uinterp = interpolate((VF.lon, VF.lat), U', Gridded(Linear()))
        Vinterp = interpolate((VF.lon, VF.lat), V', Gridded(Linear()))
        Upart::Array{Float64,1} = [Uinterp[lonP[i],latP[i]] for i in range(1,length(lonP))]
        Vpart::Array{Float64,1} = [Vinterp[lonP[i],latP[i]] for i in range(1,length(lonP))]

        #Move particles to dt/2 (Runge Kutta 2)
        k1lat::Array{Float64,1} = (DeltaT*Vpart)*(180/(R*pi))
        k1lon::Array{Float64,1} = ((DeltaT*Upart)*(180/(R*pi))).*cosd.(latP)

        #Make half the jump
        tempK2lat::Array{Float64,1} = latP + k1lat/2
        tempK2lon::Array{Float64,1} = lonP + k1lon/2

        #Interpolate VF.U and VF.V to DeltaT/2
        Uhalf= U + (UT2 - U)/2
        Vhalf= V + (VT2 - V)/2

        #Interpolate VF.U and VF.V to New particles positions using VF.U at dt/2
        UhalfInterp = interpolate((VF.lon, VF.lat), Uhalf', Gridded(Linear()))
        VhalfInterp = interpolate((VF.lon, VF.lat), Vhalf', Gridded(Linear()))
        UhalfPart::Array{Float64,1} = [UhalfInterp[tempK2lon[i],tempK2lat[i]] for i in range(1,length(lonP))]
        VhalfPart::Array{Float64,1} = [VhalfInterp[tempK2lon[i],tempK2lat[i]] for i in range(1,length(lonP))]

        #Add turbulent-diffusion
        Uturb::Array{Float64,1} = UhalfPart.*(-modelConfig.turbulentDiff + (2*modelConfig.turbulentDiff).*(rand(size(UhalfPart))))
        Vturb::Array{Float64,1} = VhalfPart.*(-modelConfig.turbulentDiff + (2*modelConfig.turbulentDiff).*(rand(size(VhalfPart))))
        UhalfPart = UhalfPart + Uturb
        VhalfPart = VhalfPart + Vturb

        #Move particles to dt
        newLatP::Array{Float64,1} = latP + (DeltaT*VhalfPart)*(180/(R*pi))
        newLonP::Array{Float64,1} = lonP + ((DeltaT*UhalfPart)*(180/(R*pi))).*cosd.(latP)

        #println("NewLatP: ", newLatP)
        #Iterate over the particles and add the new positions
        #println("currDateAdv: ", currDate)
        idLatLon = 1
        for idxPart = LiveParticlesIndx[particlesDepthIndx]
            Particles[idxPart]
            Particles[idxPart].currTimeStep = Particles[idxPart].currTimeStep + 1
            Particles[idxPart].lon[1] = newLonP[idLatLon]
            Particles[idxPart].lat[1] = newLatP[idLatLon]
            Particles[idxPart].dates[1] = currDate
            Particles[idxPart].lifeTime = Particles[idxPart].lifeTime + modelConfig.timeStep
            idLatLon += 1
        end

        #Increment the index for the current depth value
        dIndx = dIndx + 1
    end
    return Particles
end
