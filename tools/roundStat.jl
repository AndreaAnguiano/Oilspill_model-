function roundStat(nDec::Float64)
  floor_nDec = floor(nDec)
  decimals = nDec-floor_nDec
  if decimals != 0
    rand_n = rand(1)[1]
    if rand_n > decimals
      nInt = floor_nDec
    else
      nInt = ceil(nDec)
    end
  else
    nInt = nDec
  end
end
