require 'byebug'

module GroundcoverInterpreter
  TEMPLATE_FILE = 'templates.forest'

  private

  def eval_templates(forward = true)
    files_content = read(TEMPLATE_FILE)
    tree = parse(files_content)
    template_id = forward ? 0 : 1
    replacement_id = forward ? 1 : 0
    tree[:children].reduce([]) do |patterns, child|
      pattern = child[:children][template_id][:children][0]
      replacement = child[:children][replacement_id][:children][0]
      patterns << { pattern: pattern, replacement: replacement }
      patterns
    end
  end

  def apply_templates(tree, templates)
    return tree if tree[:command] == 'data'

    processed_children = tree[:children].map do |child|
      apply_templates(child, templates)
    end
    tree[:children] = processed_children

    use_first_matching_template_or_copy(tree, templates)
  end

  def use_first_matching_template_or_copy(tree, templates)
    templates.each_with_index do |template, id|
      replacements = matches(template[:pattern], tree)
      if replacements
        return apply_template(template[:replacement], replacements)
      end
    end
    tree
  end

  def matches(pattern, tree)
    if pattern[:command][0] == '$'
      [[pattern[:command], tree]]
    elsif pattern[:command] != tree[:command]
      nil
    elsif tree[:children] == []
      []
    else
      pattern_children = pattern[:children]
      tree_children = tree[:children]
      if (pattern_children.length == 1) && (pattern_children[0][:command] == '$body')
        [['$body', tree[:children]]]
      elsif pattern_children.length != tree_children.length
        nil
      else
        matches_for_children(pattern_children, tree[:children])
      end
    end
  end

  def matches_for_children(pattern_children, tree_children)
    results = []
    pattern_children.zip(tree_children).each do |pattern, tree|
      result = matches(pattern, tree)
      return nil if result == nil

      results += result
    end
    results
  end

  def apply_template(replacement, replacements)
    map = replacements.to_h
    new_replacement = deep_copy(replacement)
    assign_new_branches(new_replacement, map)
  end

  def deep_copy(tree)
    new_children = tree[:children].map {|child| deep_copy(child)}
    { command: tree[:command], children: new_children }
  end

  def assign_new_branches(tree, map)
    if tree[:command][0] == '$'
      map[tree[:command]]
    elsif (tree[:children].length) == 1 && (tree[:children][0][:command] == '$body')
      { command: tree[:command], children: map['$body'] }
    else
      new_children = tree[:children].map {|child| assign_new_branches(child, map)}
      { command: tree[:command], children: new_children }
    end
  end
end
