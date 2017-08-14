function threshold(percentage::Int64, days_percent_decay::Array{Int64,1}, time_step::Int64)
  time_percent_decay = days_percent_decay.*24./time_step
  thresholds = (1-percentage/100).^(1./time_percent_decay)
end
