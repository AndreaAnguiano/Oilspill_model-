using GeometricalPredicates
function interp(TR, particle::Particle, VF::VectorFieldsADCIRC, VFvar)
  threshold = 0.001

  d1 = [particle.lon[end], particle.lat[end]]-[getx(geta(TR[1])),getx(geta(TR[1]))]
  d2 = [particle.lon[end], particle.lat[end]]-[getx(getb(TR[1])),getx(getb(TR[1]))]
  d3 = [particle.lon[end], particle.lat[end]]-[getx(getc(TR[1])),getx(getc(TR[1]))]

  if d1[1] < threshold && d1[2] < threshold
    interp = VFVar[VF.ELE[TR[2],1]]
  elseif d2[1]< threshold && d2[2] < threshold
    interp = VFvar[VF.ELE[TR[2],2]]
  elseif d3[1]< threshold && d3[2] < threshold
    interp = VFvar[VF.ELE[TR[2],3]]
  else
    println(size(VF.ELE), "  --", size(TR))
    interp = sum((VFvar[VF.ELE[TR[2],1]]/d1)
    + (VFvar[VF.ELE[TR[2],2]]/d2) + (VFvar[VF.ELE[TR[2],3]]/d3))/sum((1/d1) + (1/d2) + (1/d3))
  end


end
