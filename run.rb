#!/usr/bin/env ruby
$LOAD_PATH << './lib'
require 'interpreter'

file_name = ARGV.first
Interpreter.new.eval_file_and_write(file_name)
