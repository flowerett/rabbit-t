#!/usr/bin/env ruby
require 'bunny'
require 'thread'

class FibonacciClient
  attr_reader :reply_queue
  attr_accessor :response, :call_id
  attr_reader :lock, :condition

  def initialize(ch, server_queue)
    @ch = ch
    @x = ch.default_exchange

    @server_queue = server_queue
    @reply_queue = ch.queue('', exclusive: true)

    @lock = Mutex.new
    @condition = ConditionVariable.new
    that = self

    @reply_queue.subscribe do |delivery_info, properties, payload|
      if properties[:correlation_id] == that.call_id
        that.response = payload.to_i
        that.lock.synchronize{that.condition.signal}
      end
    end
  end

  def call(n)
    self.call_id = self.generate_uuid

    @x.publish(
      n.to_s,
      routing_key: @server_queue,
      correlation_id: call_id,
      reply_to: @reply_queue.name
    )

    lock.synchronize{condition.wait(lock)}
    response
  end

  protected

  def generate_uuid
    "#{rand}#{rand}#{rand}"
  end
end

# create connection
conn = Bunny.new(automatically_recover: false)
conn.start

# create channel
ch = conn.create_channel

client = FibonacciClient.new(ch, 'rpc_queue')
puts " [x] Requesting fib(45)"
response = client.call(45)
puts " [.] Got #{response}"

# close a connection
ch.close
conn.close
