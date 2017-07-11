
function CreateAdy(ELE::Array{Int64,2})
  Ady = ones(length(ELE),3)
  for i = 1:length(ELE[:,1])
      j = 1
      found = 1
      while found < 3 & j > length(ELE[:,1])
        if i != j
          a = ELE[i,1] in ELE[j,1]
          b = ELE[i,2] in ELE[j,2]
          c = ELE[i,3] in ELE[j,3]
          if a + b + c == 2
            Ady[i, found] = j
            found += 1
          end
        end
      end
      j +=1
  end
  return Ady
 end
