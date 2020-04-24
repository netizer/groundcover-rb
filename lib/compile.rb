require 'byebug'

class Interpretter
  INDENTATION_BASE = 2
  TEMPLATES = [
    'call'
  ]

  def eval_file(file)
    files_content = read(file)
    tree = parse(files_content)
    new_tree = apply_templates(tree)
    output_file = convert_file_name(file)
    output_content = deparse(new_tree)
    write(output_file, output_content)
  end

  private

  def read(file)
    File.readlines(file)
  end

  def parse(lines)
    current_node = create_node(0, lines[0], nil)
    root_node = current_node
    lines[1..-1].each do |line|
      current_node = parse_line(line, current_node)
    end
    root_node
  end

  def apply_templates(tree)
    tree
  end

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

  def parse_line(line, current_node)
    indent_level, line_content = extract_indentation(line)
    ancestor_level = 1 + current_node[:indent] - indent_level
    parent_node = ancestor(current_node, ancestor_level)
    new_node = create_node(indent_level, line_content, parent_node)
    parent_node[:children] << new_node
    new_node
  end

  def ancestor(parent_node, ancestor_level)
    ancestor_node = parent_node
    ancestor_level.times do
      ancestor_node = ancestor_node[:parent]
    end
    ancestor_node
  end

  def create_node(indent_level, line, parent)
    command = line.strip
    raise "Empty lines in source files are not supported" if command == ""

    {
      indent: indent_level,
      contents: line,
      parent: parent,
      children: [],
      command: command,
      child_id: parent ? parent[:children].length : 0
    }
  end

  def extract_indentation(line)
    index = 0
    line.each_char do |char|
      if char == ' '
        index += 1
      else
        return [index / INDENTATION_BASE, line[index..-1]]
      end
    end
  end
end

file_name = ARGV.first
Interpretter.new.eval_file(file_name)
