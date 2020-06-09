#!/usr/bin/env ruby
$LOAD_PATH << './lib'
require 'interpreter'

file_name = ARGV[0]
extension = file_name.split('.').last
direction = extension == 'forest' ? :forest_to_gc : :gc_to_forest
Interpreter.new(direction).eval_file_and_write(file_name)
