using GeometricalPredicates
function findTriangle(particle::Particle, TR::Array{GeometricalPredicates.UnOrientedTriangle{Point2D},1})
  for i in length(TR)
    p = Point(particle.lat[end], particle.lon[end])
    t = TR[i]
    if intriangle(t, p) < 0
      return [t, i]
    end
  end
end
