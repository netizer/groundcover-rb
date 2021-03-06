module Groundcover
  module GeneralTreeBasedInterpreter
    INDENTATION_BASE = 2
    KEYWORD_PREFIX = 'forest_keyword_'
    FUNCTION_PREFIX = 'forest_'

    attr_accessor :interpreter_line
    attr_accessor :interpreter_row
    attr_accessor :interpreter_file

    def eval_file(file)
      tree = parse_file(file)
      evaluate(tree)
    end

    private

    def parse_file(file)
      @interpreter_file = file
      files_content = read(file)
      parse(files_content)
    end

    def read(file)
      File.readlines(file)
    end

    def parse(lines)
      current_node = create_node(0, lines[0], nil, line: 1, row: 1)
      root_node = current_node
      lines[1..-1].each_with_index do |line, id|
        current_node = parse_line(line, current_node, id + 2)
      end
      root_node
    end

    def evaluate(node)
      method_name = "#{KEYWORD_PREFIX}#{node[:command]}"
      @interpreter_line = node[:line]
      @interpreter_row = node[:row]
      send(method_name, node[:children])
    end

    def forest_keyword_call(children)
      ensure_equal(children[0][:command], 'block', children[0])
      ensure_equal(children[0][:children][0][:command], 'data', children[0])

      function_name = evaluate(children[0][:children][0])
      block = children[0][:children][1]

      function_name_parts = function_name.strip.split('.')
      method_suffix = "#{FUNCTION_PREFIX}#{function_name_parts.last}"

      method_name = (function_name_parts[0..-2] + [method_suffix]).join('__')
      public_send(method_name, block)
    end

    def forest_keyword_block(children)
      children.map do |child|
        evaluate(child)
      end
    end

    def forest_keyword_data(children)
      children.map do |child|
        child[:contents]
      end.join
    end

    def parse_line(line, current_node, line_nr)
      indent_level, line_content = extract_indentation(line)
      ancestor_level = 1 + current_node[:indent] - indent_level
      parent_node = ancestor(current_node, ancestor_level)
      new_node = create_node(indent_level, line_content, parent_node, line: line_nr, row: (indent_level + 1) * 2 + 1)
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

    def create_node(indent_level, line, parent, options = {})
      command = line.strip
      raise "Empty lines in source files are not supported" if command == ""

      {
        indent: indent_level,
        contents: line,
        parent: parent,
        children: [],
        command: command,
        child_id: parent ? parent[:children].length : 0,
        line: options[:line],
        row: options[:row],
        file: @interpreter_file
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

    def ensure_equal(arg1, arg2, node)
      return if arg1 == arg2

      path = ["#{node[:command]}(#{node[:child_id]})"]
      while node = node[:parent]
        path.push("#{node[:command]}(#{node[:child_id]})")
      end
      path_string = path.reverse.join('.')
      raise "ASSERTION ERROR: #{arg1} <> #{arg2}; path: #{path_string}"
    end

    # debugger
    def print_node(node, indent = "")
      puts indent + node[:command] + (node[:inline] ? " (inline)" : "") + "(#{node[:line]})"
      return unless node[:children]

      indent = indent + "  "
      node[:children].each do |child|
        print_node(child, indent)
      end
      nil
    end
  end
end
