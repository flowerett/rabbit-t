#!/usr/bin/env ruby
require 'bunny'

# create connection
conn = Bunny.new
conn.start

# create channel
ch = conn.create_channel

# define queue
q = ch.queue('hello')

# send a message
ch.default_exchange.publish 'Hello from Ruby', routing_key: q.name
puts ' [x] Sent a hello message'

# close a connection
conn.close
