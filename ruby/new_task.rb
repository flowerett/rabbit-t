#!/usr/bin/env ruby
require 'bunny'

# create connection
conn = Bunny.new(automatically_recover: true)
conn.start

# create channel
ch = conn.create_channel

# define queue
q = ch.queue('task_queue', durable: true)

# get message
msg = ARGV.empty? ? 'Hello from Ruby task...' : ARGV.join(' ')

# send a message
q.publish(msg, persistent: true)
puts " [x] Sent #{msg}"

# close a connection
conn.close
