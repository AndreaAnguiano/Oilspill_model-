using GeometricalPredicates
function findTriangle(particle::Particle, TR::GeometricalPredicates.UnOrientedTriangle{Point2D})
  for i in length(TR)
    p = Point(particle.lat, particle.lon)
    t = TR[i]
    if intriangle(t, p)
      return t
    end
  end
end
