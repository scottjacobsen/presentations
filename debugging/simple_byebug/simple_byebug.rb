#!/usr/bin/env ruby

require 'byebug'

def dasherizes(list)
  # display list2
  # break 10
  list2 = []
  list.each do |item|
    list2 << item.tr('_+', '-')
  end
  byebug
end

def hi
  puts 'hello world'
end

byebug

# step (notice you can't see many lines!)
dasherizes(['hello+world', 'use_the_force'])

# next (step over, don't enter method)
hi

# Make a big hash to show the limited display
hash = 50.times.each_with_object({}) do |i, h|
  h[i] = "*" * i
end

byebug
# help (show the awesome help)
puts 'Done!'
