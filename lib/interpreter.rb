require 'byebug'

class Interpreter
  INDENTATION_BASE = 2
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

  def eval_templates
    files_content = read(TEMPLATE_FILE)
    tree = parse(files_content)
    map = {}
    tree[:children].each do |child|
      key = child[:children][0][:children][0][:command]
      value = child[:children][1][:children]
      map[key] = value
    end
    map
  end

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

  def apply_templates(tree, map)
    replacements = map[tree[:command]]

    if replacements
      new_trees = apply_template(tree, replacements)
      # we repeat until there are no macros left in the subtree
      trees = []
      new_trees.each do |new_tree|
        trees += apply_templates(new_tree, map)
      end
      trees
    else
      new_children = []
      tree[:children].each do |child|
        new_children += apply_templates(child, map)
      end
      tree[:children] = new_children
      [tree]
    end
  end

  def apply_template(tree, replacement_nodes)
    substitutions = {}
    tree[:children].length.times do |id|
      substitutions["$body:#{id + 1}"] = [tree[:children][id]]
    end
    substitutions['$body'] = tree[:children]
    result = []
    replacement_nodes.each do |replacement_node|
      cloned = deep_clone(replacement_node)
      result += tree_to_replacement_trees(cloned, substitutions)
    end
    result
  end

  def tree_to_replacement_trees(tree, map)
    replacement = map[tree[:command]]
    return replacement if replacement

    children = []
    tree[:children].each do |child|
      children += tree_to_replacement_trees(child, map)
    end
    tree[:children] = children
    [tree]
  end

  def print_tree(tree, indentation = '')
    puts "#{indentation}#{tree[:command]}"
    tree[:children].each do |child|
      print_tree(child, "#{indentation}  ")
    end
    nil
  end

  def deep_clone(tree)
    children = tree[:children].map do |child|
      deep_clone(child)
    end
    copy_node(tree, children)
  end

  def copy_node(node, children)
    {
      parent: node[:parent],
      command: node[:command],
      children: children
    }
  end
end
