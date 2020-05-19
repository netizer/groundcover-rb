require 'spec_helper'
require 'interpreter'

describe Interpreter do
  it 'compiles groundcover script and produces forest script' do
    interpreter = Interpreter.new(:gc_to_forest)
    result = interpreter.eval_file('fixtures/later_now.gc')
    expected = File.read('fixtures/later_now.forest')

    expect(expected).to eq(result)
  end

  it 'compiles forest script and produces groundcover script' do
    interpreter = Interpreter.new(:forest_to_gc)
    result = interpreter.eval_file('fixtures/later_now.forest')
    expected = File.read('fixtures/later_now.gc')

    expect(expected).to eq(result)
  end
end
