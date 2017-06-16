using GLVisualize, GeometryTypes, Reactive

window = glscreen()
timesignal = bounce(linspace(3f0,3f0,400))

sphere = GLNormalMesh(Sphere{Float32}(Vec3f0(0), 1f0), 12)
N = 2
# generate some rotations
function rotation_func(t)
    t = (t == 0f0 ? 0.01f0 : t)
    Vec3f0[(t+y, t+x, t+z) for x=1:N, y=1:N, z=1:N]
end

# us Reactive.map to transform the timesignal signal into the arrow flow
flow = map(rotation_func, timesignal)

# create a visualisation
vis = visualize((sphere))
_view(vis, window)

renderloop(window)
