#!/usr/bin/env ruby
require 'bunny'

# create connection
conn = Bunny.new
conn.start

# create channel
ch = conn.create_channel

# define a topic exchange
x = ch.topic 'topic_logs'

# get message and arguments
severity = ARGV.shift || 'anonymous.info'
msg = ARGV.empty? ? 'Ruby log message...' : ARGV.join(' ')

# publish log to the exchange
x.publish(msg, routing_key: severity)
puts " [x] Sent from Ruby: #{severity}:#{msg}"

# close a connection
conn.close
