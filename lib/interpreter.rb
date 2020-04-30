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
    templates_tree = eval_templates
    files_content = read(file)
    tree = parse(files_content)
    new_tree = apply_templates(tree, templates_tree)
    deparse(new_tree)
  end

  private

  def eval_templates
    files_content = read(TEMPLATE_FILE)
    parse(files_content)
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

  def apply_templates(tree, template_tree)
    template_name = tree[:command]

    if template_name[/^m:/]
      templates = template_tree[:children]
      found = templates.find {|d| d[:children][0][:children][0][:command] == template_name }
      raise "Unknown template '#{tree[:command]}'" unless found

      replacement = found[:children][1][:children][0]
      new_tree_or_trees = apply_template(tree, replacement)
      # we repeat until there are no macros left in thesubtree
      if new_tree_or_trees.is_a?(Array)
        new_tree_or_trees.map do |new_tree|
          apply_templates(new_tree, template_tree)
        end
      else
        apply_templates(new_tree_or_trees, template_tree)
      end
    else
      new_children = []
      tree[:children].each_with_index do |child, index|
        child_or_children = apply_templates(child, template_tree)
        if child_or_children.is_a?(Array)
          new_children += child_or_children
        else
          new_children << child_or_children
        end
      end
      tree[:children] = new_children
      tree
    end
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

  def apply_template(tree, replacement_node)
    substitutions = {}
    tree[:children].length.times do |id|
      substitutions["$body:#{id + 1}"] = tree[:children][id]
    end
    substitutions['$body'] = tree[:children]
    cloned = deep_clone(replacement_node)
    substitute_keywords_with_trees(cloned, substitutions)
  end

  def substitute_keywords_with_trees(tree, map)
    if (tree[:children] == [])
      replacement_pair = map.find { |k, _v| tree[:command] == k }
      if replacement_pair
        replacement = replacement_pair.last
        return replacement
      end
    end
    children = []
    tree[:children].each do |child|
      child_or_children = substitute_keywords_with_trees(child, map)
      if child_or_children.is_a?(Array)
        children += child_or_children
      else
        children << child_or_children
      end
    end
    tree[:children] = children
    tree
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
