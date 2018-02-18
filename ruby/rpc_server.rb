#!/usr/bin/env ruby
require 'bunny'

class FibonacciServer
  def initialize(ch)
    @ch = ch
  end

  def start(queue_name)
    @q = @ch.queue(queue_name)
    @x = @ch.default_exchange

    @q.subscribe(block: true) do |dilivery_info, properties, payload|
      n = payload.to_i
      p "calculating fib(#{n})..."
      st = Time.now
      r = self.class.fib(n)
      p "sending result: #{r}, spent: #{Time.now - st}"

      @x.publish(
        r.to_s,
        routing_key: properties.reply_to,
        correlation_id: properties.correlation_id
      )
    end
  end

  def self.fib(n)
    case n
    when 0 then 0
    when 1 then 1
    else
      fib(n - 1) + fib(n - 2)
    end
  end
end

# create connection
conn = Bunny.new
conn.start

# create channel
ch = conn.create_channel

begin
  server = FibonacciServer.new(ch)
  puts ' [x] Awaiting RPC requests'
  server.start('rpc_queue')
rescue Interrupt => _exception
  puts ' [*] closing connection...'
  ch.close
  conn.close
  exit 0
end
