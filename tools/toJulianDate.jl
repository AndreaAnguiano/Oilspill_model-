
#function that transform a DateTime object to Float64

# function toJulianDate(Date)
#   return Int64(Dates.datetime2julian(Date)-Dates.datetime2julian(DateTime(Dates.year(Date)-1,12,31)))
# end

toJulianDate(Date::DateTime) = convert(Int64, Dates.datetime2julian(Date)-Dates.datetime2julian(DateTime(Dates.year(Date)-1,12,31)))
