# spec/lib/file1_spec.rb
require "spec_helper"
require "appy_parse.rb"

describe AppyParse do
  ap = AppyParse.new
  it 'returns a string' do
    file = 'sample_appysphere.log'
    output = ap.parse(file)

    expect(output).to be_a(String)
  end
end
