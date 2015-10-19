require 'rubygems'
require 'colorize'

require_relative '../lib/harrot'
require_relative '../lib/harrot_client'

describe 'harrot' do
  before(:all) do
    Harrot::Server.start(6543)
  end

  after(:all) do
    Harrot::Server.stop(6543)
  end

  it 'should add a new stub' do
    Harrot::Client.config(port: 6543)
    stub_1 = {
        url: '/test123',
        response: {
            body: 'Hello'
        }
    }

    Harrot::Client.add_stub(stub_1)

    expect(Net::HTTP.get_response(URI.parse('http://localhost:6543/test123')).body).to eq('Hello')

    # Using to_json to normalize symbols and strings
    expect(Harrot::Client.get_stubs.to_json).to eq([stub_1].to_json)
  end
end
