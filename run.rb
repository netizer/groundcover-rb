require './lib/interpreter'

file_name = ARGV.first
Interpreter.new.eval_file_and_write(file_name)
