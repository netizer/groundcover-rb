require 'spec_helper'
require 'interpreter'

describe Interpreter do
  describe 'groundcover -> forest' do
    it 'transpiles an easy case' do
      interpreter = Interpreter.new(:gc_to_forest)
      result = interpreter.eval_file_and_deparse('fixtures/small.gc')
      expected = File.read('fixtures/small.forest')

      expect(result).to eq(expected)
    end

    it 'transpiles a complex case' do
      interpreter = Interpreter.new(:gc_to_forest)
      result = interpreter.eval_file_and_deparse('fixtures/later_now.gc')
      expected = File.read('fixtures/later_now.forest')

      expect(result).to eq(expected)
    end
  end

  describe 'forest -> groundcover' do
    it 'transpiles an easy case' do
      interpreter = Interpreter.new(:forest_to_gc)
      result = interpreter.eval_file_and_deparse('fixtures/small.forest')
      expected = File.read('fixtures/small.gc')

      expect(result).to eq(expected)
    end

    it 'transpiles an complex case' do
      interpreter = Interpreter.new(:forest_to_gc)
      result = interpreter.eval_file_and_deparse('fixtures/later_now.forest')
      expected = File.read('fixtures/later_now.gc')

      expect(result).to eq(expected)
    end
  end
end
