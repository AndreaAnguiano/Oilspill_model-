

startDate = DateTime(2017,1,1)
ArrVF = [0.0,0.0,0.0]
VFtest = vectorFields(ArrVF,ArrVF,ArrVF,ArrVF,ArrVF,ArrVF,ArrVF,ArrVF,112,0)
Days = [112,113]
deltaT = 8
path = "ArchivosEjemplo/"
for Day in Days
  for Hour in range(0,deltaT,convert(Int64,24/deltaT))
    println(Hour)
    VF = readUV(deltaT,Hour,Day,VFtest)

  end
end

function readUV(deltaT,Hour,Day, VF)
#---------------- currents --------------------------
  newday = Day + 1
  subfilefloor = convert(Int64,floor(Hour/6)+ 1)
  subfileceil = convert(Int64,ceil((Hour+0.1)/6)+ 1)
  println("Hour: ", Hour, "CurrHour: ", VF.CurrHour, "currDay: ", VF.currDay)
  if Hour == 0
    if VF.currDay == Day
      println("Read archv.2010_$Day _00_3z.nc")
      println("Read archv.2010_$newday _00_3z.nc")
    else
      println("Use archv.2010_$Day _00_3z.nc")
      println("Read archv.2010_$newday _00_3z.nc")
    end
  else
    println("Use archv.2010_$Day _00_3z.nc")
    println("Use archv.2010_$newday _00_3z.nc")
  end

#----------------- winds------------
  if Hour == 0 && VF.currDay == Day
    println("Read Dia_$Day _$subfilefloor.nc")
    println("Read Dia_$Day _$subfileceil.nc")
    VF.ut2 = ncread(readAtmFile, "U_Viento")
    VF.vt2 = ncread(readAtmFileT2, "V_Viento")

  else #Hour == 0 && VF.currDay == Day
    if floor(Hour/6) != floor(VF.CurrHour/6)
      println("Use Dia_$Day _$subfilefloor.nc")
      if subfileceil > 4
        println("Read Dia_$newday _1.nc")
      else #subfileceil > 4
        println("Read Dia_$Day _$subfileceil.nc")
      end
    else #floor(Hour/6) != floor(VF.CurrHour)
      println("Use Dia_$Day _$subfilefloor.nc")
      if subfileceil > 4
        println("Use Dia_$newday _1.nc")
      else  #subfileceil > 4
        println("Use Dia_$Day _$subfileceil")
      end
    end
  end
  VF.currDay = Day
  VF.CurrHour = Hour

return VF
end
