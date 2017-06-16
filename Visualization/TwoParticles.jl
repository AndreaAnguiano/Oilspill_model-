#packages
using GLAbstraction, MeshIO, Colors
using GLVisualize, GeometryTypes, Reactive, ColorTypes

#create a window
window = glscreen()

startDate=[DateTime(1996,7,7), DateTime(2001,1,1)]
lat1 = [116.0, 117.0, 118.0, 119.0]
lon1 = [120.0, 121.0, 122.0, 123.0]
lat2 = 2*lat1
lon2 = 2*lon1
depths = 1
lifeTime = 0
component = 0
currTimeStep = 1
isAlive = true
status = "M"

#create the particles

particles = [Particle(startDate, lat1 ,lon1, depths, lifeTime, component, currTimeStep, isAlive, status),
Particle(startDate, lat1 ,lon1, depths, lifeTime, component, currTimeStep, isAlive, status)]
N = length(particles)


# convert a particle to a point
function to_points(data, particles)
    @inbounds for (i,p) in enumerate(particles)
        data[i] = to_points(p)
    end
    data
end


timesignal = bounce(linspace(1,1,length(particles)))

 particlesToPoints = map(to_points, particles)
 vis = visualize(particlesToPoints)
_view(vis, window)
renderloop(window)



S
