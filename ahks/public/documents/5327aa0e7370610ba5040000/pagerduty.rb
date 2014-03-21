#!/usr/bin/ruby

# For a given duration of time, returns the percentage of time in which there was at least one incident open.
#
# query  - The 2 element Array that contains the start and finish time of a query.
# incidents - An Array of 2-element-arrays, each of which contains a trigger time and resolve time for that incident.
#
# Examples
#
#   assert_percentage_time_at_least_one_incident([10,20], [[8, 15], [18,19]])
#   # => 0.6
#
# Returns percentage of time in which there was at least one incident open

def assert_percentage_time_at_least_one_incident(query, incidents) 

	range = *(query[0]..query[1]) 
	len = range.size - 1 # gives the correct number of intervals
	
	count = 0
	interval = []

	# The following loop finds all the intervals when at least one incident is open and stores them in "interval"
	incidents.uniq.each do |i|
		tmp = *(i[0]...i[1])
		interval = interval | (tmp & range)
	end

	# The following loop increments count when a unique interval starts.
	# eg: count = 1 when interval = [10,11,12,13,14,15,18,19].
	# If count is x, then total number of unique intervals = x+1. 
	interval.each_cons(2) do |element,next_element|
		if element+1 != next_element
			count += 1
		end
	end

	interval_size = interval.size > len ? len : interval.size
	# len = range.size - 1, in the case where all the intervals are being used then interval_size is range.size (len+1).

	0 == count ? (interval_size).to_f/len : (interval_size-count+1).to_f/len



end

#	query = [10,20]
#	query = [10,16]		
	query = [40, 70]
#	incidents = [[8, 13], [14, 15]]
#	incidents = [[8, 13], [14, 16], [20,23]]
#	incidents = [[8, 15],[18,19]]
	incidents = [[50, 60], [50, 62], [50, 65]]

p assert_percentage_time_at_least_one_incident(query, incidents) 

