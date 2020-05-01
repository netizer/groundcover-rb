require 'byebug'

module GroundcoverInterpreter

  TEMPLATE_FILE = 'templates.forest'

  private

  def eval_templates
    files_content = read(TEMPLATE_FILE)
    tree = parse(files_content)
    tree[:children].reduce({}) do |map, child|
      key = child[:children][0][:children][0][:command]
      value = child[:children][1][:children]
      map[key] = value
      map
    end
  end

  def apply_templates(tree, map)
    apply_templates_for_node(tree, map)
  end

  def apply_templates_for_nodes(trees, map)
    trees.reduce([]) do |new_trees, tree|
      new_trees + apply_templates_for_node(tree, map)
    end
  end

  def apply_templates_for_node(tree, map)
    replacements = map[tree[:command]]

    if replacements
      new_trees = apply_template(tree, replacements)
      apply_templates_for_nodes(new_trees, map)
    else
      tree[:children] = apply_templates_for_nodes(tree[:children], map)
      [tree]
    end
  end

  def apply_template(tree, replacement_nodes)
    substitutions = build_substitutions_hash(tree)
    replacement_nodes.reduce([]) do |result, replacement_node|
      cloned = deep_clone(replacement_node)
      result + tree_to_replacement_trees(cloned, substitutions)
    end
  end

  def build_substitutions_hash(tree)
    substitutions = {}
    tree[:children].length.times do |id|
      substitutions["$body:#{id + 1}"] = [tree[:children][id]]
    end
    substitutions['$body'] = tree[:children]
    substitutions
  end

  def tree_to_replacement_trees(tree, map)
    replacement = map[tree[:command]]
    return replacement if replacement

    tree[:children] = tree[:children].reduce([]) do |children, child|
      children + tree_to_replacement_trees(child, map)
    end
    [tree]
  end

  def deep_clone(node)
    {
      parent: node[:parent],
      command: node[:command],
      children: node[:children].map { |child| deep_clone(child) }
    }
  end
end
