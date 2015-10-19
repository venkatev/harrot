require 'json'
require 'net/http'

#
# A lightweight HTTP stub using rack.
#
# 'HTTP Parrot' -> Harrot
#
# Adding a stub:
#   POST to '/stubs/add' with the stub in the format below.
#
# Stub format:
# {
#   url: '/api/path1/path2'
#   response: {
#     status: 200 (default),
#     body: "Hello",
#     content_type: 'application/json' (default),
#     headers: (HTTP headers),
#     wait: 0 (Artificial delay in response. Useful to simulating real-world response times)
# }
#
# Getting all stubs:
#   GET /stubs
#
# Health check:
#   /ping
#
class Harrot
  PID_FILE = 'harrot.pid'
  LOG_FILE = 'harrot.log'

  @@stubs = []
  @@port = nil
  @@is_running = false

  def self.start(port)
    @@port = port
    stop_server

    print 'Starting harrot HTTP stub '.colorize(:light_black)

    pid = spawn("exec unicorn -p #{port} #{File.dirname(__FILE__)}/../harrot_server.ru > #{LOG_FILE} 2>&1")
    server_pid(pid)

    # Wait for the rack server to start
    if wait_for_server_startup(port)
      print "[Done]\n".colorize(:light_black)
      @@is_running = true
    else
      print "Mock server couldn't be started on port #{port}".colorize(:red)
    end
  end

  def self.server_pid(pid = nil)
    if pid.nil?
      return nil unless File.exists?(PID_FILE)
      File.read(PID_FILE)
    else
      File.open(PID_FILE, 'w') { |f| f.write(pid) }
    end
  end

  def self.wait_for_server_startup(port)
    max_wait_time = 10
    delay = 0.1

    (max_wait_time / delay).to_i.times do
      begin
        Net::HTTP.get_response(URI.parse("http://localhost:#{port}/ping"))
        @connected = true
        break
      rescue Errno::ECONNREFUSED => e
        print '.'.colorize(:light_black)

        sleep(delay)
        next
      end
    end

    return @connected
  end

  def self.stop_server
    pid = server_pid

    if pid
      begin
        Process.kill('SIGKILL', pid.to_i)
      rescue Errno::ESRCH
        # process exited normally
      end
    end

    delete_server_pid
    @@is_running = false
  end

  def self.delete_server_pid
    File.delete(PID_FILE) if File.exists?(PID_FILE)
  end

  def call(env)
    req = Rack::Request.new(env)

    if req.path_info == '/ping'
      return [
          200,
          {},
          ['']
      ]
    elsif req.path_info == '/stubs' && req.request_method == 'GET'
      # List stubs
      return [
          200,
          {},
          [@@stubs.to_json]
      ]
    elsif req.path_info == '/stubs/add' && req.request_method == 'POST'
      # Add new stub
      stub_json = req.body.read
      @@stubs << JSON.parse(stub_json)
      return [
          200,
          {},
          []
      ]
    end

    # Get the first matching stub and return the response.
    @@stubs.each do |stub|
      if req.path_info.include?(stub['url'])
        response_stub = stub['response'] || {}

        if response_stub['wait']
          # Artificial delay in response.
          sleep(response_stub['wait'].to_i)
        end

        response_body = response_stub['body']

        return [
            response_stub['status'] || 200,
            {'Content-Type' => 'application/json'}.merge(response_stub['headers'] || {}),
            [response_body || '(No content)']
        ]
      end
    end

    return [
        404,
        {'Content-Type' => 'text/html'},
        ["Unknown url '#{req.path_info}'. Forgot to add the stub?"]
    ]
  end
end