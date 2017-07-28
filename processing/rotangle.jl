function rotangle(U,V)
  #Wind components
  # U
  # V
  # d_angle = Deflection angle matrix proposed by Samuels(1982) [°]
  #W =  Wind intensity
  # nu = Kinematics viscosity
  # g =
  # d_angle = 25*exp(-10⁻8* W^3/nu*g)

  mu = 1.307*(1/10^6)
  g = 9.81
  W = sqrt.(U.^2+V.^2)
  # c = mu * g
  # d_angle=25*exp(-(10^-8).*(W.^3/(mu*g)))
  d_angle = 34-7.5*(W).^(1/2)
  angled = d_angle*(2 * pi)/360

  #Create the complex vector of U and V
  Z = complex.(U, V)

  #Calculate the angle of complex vectors in degrees
  ang = angle.(Z)

  #Magnitude of currents
  r = abs.(ang)

  #Now rotate all currents with Euler expression for complex numbers
   complex_vectors = r.*exp.(im*(ang - angled))

  #Components of rotated vectors
  Ur = real.(complex_vectors)
  Vr = imag.(complex_vectors)

  [Ur, Vr]

end
