require 'rubygems'
require 'colorize'

require_relative '../lib/harrot'
require_relative '../lib/harrot_client'

describe 'harrot' do
  before(:all) do
    Harrot::Server.start(6543)
    Harrot::Client.config(port: 6543)
  end

  after(:all) do
    Harrot::Server.stop(6543)
  end

  it 'should add a new stub' do
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

  it 'should server requests concurrently' do
    delay_per_request = 2
    stub_1 = {
        url: '/test123',
        response: {
            body: 'Hello',
            wait: delay_per_request
        }
    }

    Harrot::Client.add_stub(stub_1)

    start_time = Time.now
    threads = []
    num_parallel_requests = 3

    num_parallel_requests.times do
      t = Thread.new do
        expect(Net::HTTP.get_response(URI.parse('http://localhost:6543/test123')).body).to eq('Hello')
      end

      threads << t
    end

    threads.each(&:join)

    time_taken = Time.now - start_time

    # If responding serially, the total time would be at least 3 seconds (3 requests * 1 second each).
    # Asserting the total time is within that.
    expect(time_taken).to be < (num_parallel_requests * delay_per_request)
  end
end
