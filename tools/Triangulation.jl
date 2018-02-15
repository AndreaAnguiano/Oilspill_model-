using GeometricalPredicates
function triang(VF::VectorFieldsADCIRC, P::Array{Float64,2})

  TR = Array{GeometricalPredicates.UnOrientedTriangle{Point2D}}(length(VF.ELE))
  for i in VF.ELE
    P1 = Point(P[VF.ELE[i, 1],1], P[VF.ELE[i, 1],2])
    P2 = Point(P[VF.ELE[i, 2],1], P[VF.ELE[i, 2],2])
    P3 = Point(P[VF.ELE[i, 3],1], P[VF.ELE[i, 3],2])
    push!(TR,Primitive(P1,P2,P3))
  end
  return TR
end
