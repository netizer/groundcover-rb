require 'byebug'
require 'forest_interpreter'

class Interpreter
  include ForestInterpreter

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

  def apply_templates(tree, map)
    apply_templates_for_node(tree, map)
  end

  def apply_templates_for_nodes(trees, map)
    new_trees = []
    trees.each do |tree|
      new_trees += apply_templates_for_node(tree, map)
    end
    new_trees
  end

  def apply_templates_for_node(tree, map)
    replacements = map[tree[:command]]

    if replacements
      new_trees = apply_template(tree, replacements)
      # we repeat until there are no macros left in the subtree
      apply_templates_for_nodes(new_trees, map)
    else
      tree[:children] = apply_templates_for_nodes(tree[:children], map)
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
