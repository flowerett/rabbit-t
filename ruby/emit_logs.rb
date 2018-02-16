#!/usr/bin/env ruby
require 'bunny'

# create connection
conn = Bunny.new
conn.start

# create channel
ch = conn.create_channel

# define exchange
x = ch.fanout 'logs'

# get message
msg = ARGV.empty? ? 'Ruby log message...' : ARGV.join(' ')

# publish log to the exchange
x.publish(msg)
puts " [x] Sent #{msg}"

# close a connection
conn.close
