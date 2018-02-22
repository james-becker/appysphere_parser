# spec/lib/file1_spec.rb
require "spec_helper"
require "appy_parse.rb"

describe AppyParse do
  ap = AppyParse.new

  file = 'sample_appysphere.log'
  output = ap.parseIO(file)

  it 'returns a hash' do
    expect(output).to be_a(Hash)
  end

  it 'returns four correct objects' do
    expect(output).to have_key('camera_ip_calls_by_home')
    expect(output).to have_key('response_times')
    expect(output).to have_key('service_times_ranking')
    expect(output).to have_key('entries_processed')
  end

  it 'returns the correct number of entries processed' do
    expect(output['entries_processed']).to equal(6637)
  end

end
