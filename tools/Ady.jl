function CreateAdy(ELE::Array{Int64,2})
  Ady = ones(length(ELE),3)
   for i = 1:length(ELE)
     found = 0
     j = 1
     while found < 3
       if i != j
        a = ELE[j,1] in ELE[i,1]
        b = ELE[j,2] in ELE[i,2]
        c = ELE[j,3] in ELE[i,3]
        if a + b + c == 2
          Ady[i, found] = j
          found += 1

        end
       end
     end
   end
   return Ady
end
