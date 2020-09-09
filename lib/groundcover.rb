require 'groundcover/interpreter'

# This file should be included to Forest Dependencies
# to make Groundcover available within Forest.
module Groundcover
  def groundcover__forest_parse_to_forest(file_name)
    interpreter = Interpreter.new(direction = :to_forest)
    interpreter.eval_file(file_name)
  end

  def self.included(klass)
    klass.register_language(
      'gc' => {
        name: 'Groundcover',
        forest_command: 'groundcover.parse_text_to_forest',
        method: :groundcover__forest_parse_to_forest
      }
    )
  end
end
