require 'byebug'

module GroundcoverInterpreter
  TEMPLATE_FILE = File.join(__dir__, '..', 'templates.forest')

  private

  def groundcover(tree, direction)
    forward = (@direction == :gc_to_forest)
    map = eval_templates(forward)
    tree = align_children(tree, false)
    tree = apply_templates(tree, map)
    tree = inline_children(tree)
    tree = add_parents(tree)
    tree
  end

  def add_parents(tree, parent = nil)
    tree[:parent] = parent
    tree[:children].each do |child|
      add_parents(child, tree)
    end
    tree
  end

  def eval_templates(forward = true)
    files_content = read(TEMPLATE_FILE)
    tree = parse(files_content)
    tree[:children].reduce([]) do |patterns, child|
      pattern = child[:children][forward ? 0 : 1][:children][0]
      replacement = child[:children][forward ? 1 : 0][:children][0]
      pattern = align_children(pattern, true)
      replacement = align_children(replacement, true)
      patterns + [{ pattern: pattern, replacement: replacement }]
    end
  end

  def apply_templates(tree, templates)
    return tree if tree[:command] == 'data'

    tree = use_first_matching_template_or_copy(tree, templates)
    tree[:children] = tree[:children].map do |child|
      apply_templates(child, templates)
    end
    tree
  end

  def inline_children(tree)
    new_command_parts = [tree[:command]]
    new_children = []
    tree[:children].each do |child|
      new_child = inline_children(child)
      if child[:inline]
        new_command_parts << new_child[:command]
      else
        new_children << new_child
      end
    end
    tree[:children] = new_children
    tree[:command] = new_command_parts.join(' ')
    tree
  end

  def align_children(tree, mark)
    return tree if tree[:command] == 'data'

    inline_parts = tree[:command].split(' ')
    inline_children = inline_parts[1..-1].map do |child|
      { command: child, inline: mark, children: [], line: tree[:line], row: tree[:row] }
    end
    new_children = tree[:children].map do |child|
      align_children(child, mark)
    end

    tree[:children] = inline_children + new_children
    tree[:command] = inline_parts[0]
    tree
  end

  def use_first_matching_template_or_copy(tree, templates)
    templates.each do |template|
      matches = find_matches(template[:pattern], tree)
      return apply_template(template[:replacement], matches, tree) if matches
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

  def apply_template(replacement, matches, original_tree)
    apply_matches(deep_copy(replacement), matches, original_tree)
  end

  def deep_copy(tree)
    {
      command: tree[:command],
      inline: tree[:inline],
      children: tree[:children].map { |child| deep_copy(child) },
      line: tree[:line],
      row: tree[:row],
      file: tree[:file]
    }
  end

  def apply_matches(tree, matches, original_tree)
    command = tree[:command]
    match = matches[command]
    children = tree[:children]
    result =
      if command[0] == '$'
        match
      elsif (children.length == 1) && (children[0][:command] == '$body')
        { command: command, children: matches['$body'] }
      else
        new_children = children.map { |child| apply_matches(child, matches, original_tree) }
        { command: command, children: new_children }
      end
    # The part of the template that does not correspond to the node
    # in the original tree, but rather to the node copied
    # from the templates.forest file, should have line and row of the branch
    # from the original tree that corresponds to the root of the template.
    source = match || original_tree
    result.merge(inline: tree[:inline], line: source[:line], row: source[:row], file: source[:file])
  end
end
