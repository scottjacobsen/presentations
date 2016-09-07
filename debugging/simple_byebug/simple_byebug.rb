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

# help (show the awesome help)
puts 'Done!'
