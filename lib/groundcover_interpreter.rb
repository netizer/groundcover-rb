require 'byebug'

# 1. We have a groundcover tree and a templates.forest file
# 2. We convert templates.forest to a template substitution map
#    which is a map from names of special node names
#    in the groundcover tree, to the templates.
#    Have in mind that each template can contain a list of nodes,
#    chich could be useful, but currently is not used.
#    In that case the node would be replaced with multiple nodes
#    on the same tree depth level.
# 3. We traverse the groundcover tree searching for a node
#    with a command matching any key from the template substitution map.
# 4. For each such node:
#    a) We create a argument substitution map
#       from template erguments (e.g. `$body:0`) to node's children (`$body:0`)
#       and groups of them (`$body`)
#    b) We create a copy of the corresponding template.
#    c) Then we the substitute template arguments (e.g. `$body:1`)
#       with the node's children according to the argument substitution map.
#    d) We replace the node with this template.
#    e) We proceed with the same process for the whole branch
#       that we just inserted.
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
    apply_templates_for_node(tree, map).first
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
