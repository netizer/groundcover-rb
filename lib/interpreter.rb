require 'byebug'
require 'forest_interpreter'
require 'groundcover_interpreter'

class Interpreter
  include ForestInterpreter
  include GroundcoverInterpreter

  TEMPLATE_FILE = 'templates.forest'

  def eval_file_and_write(file)
    output_content = eval_file(file)
    output_file = convert_file_name(file)
    write(output_file, output_content)
  end

  def eval_file(file)
    map = eval_templates
    files_content = read(file)
    tree = parse(files_content)
    new_tree = apply_templates(tree, map).first
    deparse(new_tree)
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
    new_file = file_name.gsub(/\.tforest\Z/, '.forest')
    raise "Output file should not be the same as source file." if file_name == new_file
    new_file
  end

  def write(file_name, content)
    File.open(file_name, 'w') do |file|
      file.write(content)
    end
  end
end
