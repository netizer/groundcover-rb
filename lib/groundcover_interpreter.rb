require 'byebug'

module GroundcoverInterpreter
  TEMPLATE_FILE = 'templates.forest'

  private

  def eval_templates(forward = true)
    files_content = read(TEMPLATE_FILE)
    tree = parse(files_content)
    tree[:children].reduce([]) do |patterns, child|
      pattern = child[:children][forward ? 0 : 1][:children][0]
      replacement = child[:children][forward ? 1 : 0][:children][0]
      patterns + [{ pattern: pattern, replacement: replacement }]
    end
  end

  def apply_templates(tree, templates)
    return tree if tree[:command] == 'data'

    tree[:children] = tree[:children].map do |child|
      apply_templates(child, templates)
    end
    use_first_matching_template_or_copy(tree, templates)
  end

  def use_first_matching_template_or_copy(tree, templates)
    templates.each do |template|
      matches = find_matches(template[:pattern], tree)
      return apply_template(template[:replacement], matches) if matches
    end
    tree
  end

  def find_matches(pattern, tree)
    if pattern[:command][0] == '$'
      { pattern[:command] => tree }
    elsif pattern[:command] != tree[:command]
      nil
    elsif tree[:children] == []
      {}
    elsif pattern[:children][0][:command] == '$body'
      { '$body' => tree[:children] }
    elsif pattern[:children].length != tree[:children].length
      nil
    else
      pattern[:children].zip(tree[:children]).map do |pattern, tree|
        find_matches(pattern, tree) || (return nil)
      end.inject(&:merge)
    end
  end

  def apply_template(replacement, matches)
    apply_matches(deep_copy(replacement), matches)
  end

  def deep_copy(tree)
    {
      command: tree[:command],
      children: tree[:children].map { |child| deep_copy(child) }
    }
  end

  def apply_matches(tree, matches)
    if tree[:command][0] == '$'
      matches[tree[:command]]
    elsif (tree[:children].length == 1) && (tree[:children][0][:command] == '$body')
      { command: tree[:command], children: matches['$body'] }
    else
      new_children = tree[:children].map { |child| apply_matches(child, matches) }
      { command: tree[:command], children: new_children }
    end
  end
end
