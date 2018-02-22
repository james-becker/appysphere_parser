# spec/lib/file1_spec.rb
require "spec_helper"
require "appy_parse.rb"

describe AppyParse do
  it 'returns a text file' do
    appy_parse = AppyParse.new

    reversed_string = string_changer.reverse_and_save('example string')

    expect(reversed_string).to eq 'gnirts elpmaxe'
  end
end
