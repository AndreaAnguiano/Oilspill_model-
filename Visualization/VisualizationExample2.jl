function profile_test(n)
    for i = 1:n
        A = randn(100,100,20)
        m = maximum(A)
        Afft = fft(A)
        Am = mapslices(sum, A, 2)
        B = A[:,:,5]
        Bsort = mapslices(sort, B, 1)
        b = rand(100)
        C = B.*b
    end
end

profile_test(1)  # run once to trigger compilation
Profile.clear()  # in case we have any previous profiling data
@profile profile_test(10)

using ProfileView

ProfileView.view()

a = rand(1,200)
b = 34*rand(1,200)
c = 3*rand(1,200)
using Plots
scatter3d(a, b, c)
gui()
