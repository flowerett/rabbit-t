#!/usr/bin/env ruby
require 'bunny'

abort("Usage: #{$PROGRAM_NAME} [info] [warning] [error]") if ARGV.empty?

# create connection
conn = Bunny.new
conn.start

# create channel
ch = conn.create_channel

# define an exclusive queue, bind to an exchange
x = ch.direct('direct_logs')
q = ch.queue('', exclusive: true)

# bind using routing key
ARGV.each do |severity|
  q.bind(x, routing_key: severity)
end

puts ' [*] waiting for messages. To exit press Ctrl+C'

begin
  q.subscribe(block: true) do |delivery_info, _properties, body|
    puts " [x] #{delivery_info.routing_key} received in Ruby: #{body}"
  end
rescue Interrupt => _exception
  puts ' [*] closing connection...'
  conn.close
  exit 0
end
