require 'spec_helper'
require 'interpreter'

describe Interpreter do
  it 'compiles tforest script and produces forest script' do
    result = Interpreter.new.eval_file('fixtures/later_now.tforest')
    expected = File.read('fixtures/expected.forest')

    expect(expected).to eq(result)
  end
end
