require 'byebug'
require 'interpreter'

module Groundcover
  def groundcover__forest_parse_to_forest(node)
    file_name = node[:children][0][:command]
    interpreter = Interpreter.new(direction = :gc_to_forest)
    forest_tree = interpreter.eval_file(file_name)
    evaluate(forest_tree)
  end
end
