#
# Client for managing Harrot stubs.
#
module Harrot
  class Client
    def self.config(host, port)
      @@host = host
      @@port = port
    end

    #
    # Sample stub
    #
    #   {
    #     url: '/api/path1/path2'
    #     response: {
    #       status: 200 (default),
    #       body: "Hello",
    #       content_type: 'application/json' (default),
    #       headers: (HTTP headers),
    #       wait: 0 (Artificial delay in response. Useful to simulating real-world response times)
    #   }
    #
    def self.add_stub(stub_config)
      if !server_running?
        raise 'Start the stub server first'
      end

      http = Net::HTTP.new(@@host, @@port)
      http.request(Net::HTTP::Post.new('/stubs/add'), stub_config.to_json)
    end

    def self.get_stubs
      stubs_json = Net::HTTP.get_response(URI.parse("http://#{@@host}:#{@@port}/stubs")).body
      return JSON.parse(stubs_json)
    end

    private

    def self.server_running?
      response = Net::HTTP.get_response(URI.parse("http://#{@@host}:#{@@port}/ping"))
      return response.code == '200'
    end
  end
end