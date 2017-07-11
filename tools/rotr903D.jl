function rotr903D(matrix::Array{Float32,3}, k::Int64)
  siz = size(matrix)
  newMatrix = zeros(siz[2],siz[1], siz[3])
  for dim in range(1,ndims(matrix))
   newMatrix[:,:,dim] = rotr90(matrix[:, :, dim], k)
  end
  return newMatrix
end
