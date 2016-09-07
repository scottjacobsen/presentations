#!/usr/bin/env ruby

require 'byebug'
require 'pry'
require 'active_support/core_ext/hash/reverse_merge'

def dasherizes(list)
  # edit -c
  list2 = []
  list.each do |item|
    list2 << item.tr('_+', '-')
  end
  binding.pry
end

def hi
  puts 'hello world'
end

binding.pry

# step (notice you can't see many lines!)
dasherizes(['hello+world', 'use_the_force'])

# next (step over, don't enter method)
hi

# Make a big hash to show the limited display
hash = 50.times.each_with_object({}) do |i, h|
  h[i] = "*" * i
end
binding.pry
# show hash

binding.pry
# help (show the awesome help)

binding.pry
# demo pry-doc (? and $ "foo".length)

binding.pry
# demo pry-doc (? and $ hash.reverse_merge)

binding.pry
# cd hash and look around

puts 'Done!'
