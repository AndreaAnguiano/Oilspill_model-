using DataFrames
function readData(FileName::String; separator=';', header=true)
  File = readtable(FileName, header = header,  separator = separator)
  Arr = zeros(length(File[1]),length(File))
  for idx in range(1,length(File[1]))
    date = File[idx, 1]
    lat = File[idx, 2]
    lon = File[idx, 3]
    tot = File[idx, 4]
    typ = File[idx, 5]
    arrTemp = [date, late, lon, tot, typ]
  end
  return(ArraySpillByDay)
end
