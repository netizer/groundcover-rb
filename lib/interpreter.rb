require 'byebug'
require 'forest_interpreter'
require 'groundcover_interpreter'

class Interpreter
  include ForestInterpreter
  include GroundcoverInterpreter

  DIRECTIONS = [:gc_to_forest, :forest_to_gc]

  def initialize(direction = :gc_to_forest)
    unless DIRECTIONS.include? direction
      rise "Wrong interpretter parameter #{direction}"
    end

    @direction = direction
  end

  def eval_file_and_write(file)
    output_content = eval_file(file)
    output_file = convert_file_name(file)
    write(output_file, output_content)
  end

  def eval_file_and_deparse(file)
    tree = eval_file(file)
    deparse(tree)
  end

  def eval_file(file)
    @interpreter_file = file
    files_content = read(file)
    eval_text(files_content)
  end

  def eval_text(files_content)
    tree = parse(files_content)
    groundcover(tree, @direction)
  end

  private

  def deparse(tree, indent = 0)
    head = " " * indent * INDENTATION_BASE + tree[:command]
    has_children = !tree[:children].empty?
    rest = has_children ? tree[:children].map do |ch|
      deparse(ch, indent + 1)
    end.join : ""
    "#{head}\n#{rest}"
  end

  def convert_file_name(file_name)
    new_file =
      if @direction == :gc_to_forest
        file_name.gsub(/\.gc\Z/, '.forest')
      else
        file_name.gsub(/\.forest\Z/, '.gc')
      end
    raise "Output file should not be the same as source file." if file_name == new_file
    new_file
  end

  def write(file_name, content)
    File.open(file_name, 'w') do |file|
      file.write(content)
    end
  end
end
