#!/usr/bin/env ruby
$LOAD_PATH << './lib'
require 'groundcover/interpreter'

file_name = ARGV[0]
extension = file_name.split('.').last
direction = extension == 'forest' ? :from_forest : :to_forest
Groundcover::Interpreter.new(direction).eval_file_and_write(file_name)
