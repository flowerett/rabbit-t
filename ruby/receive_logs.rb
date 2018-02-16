#!/usr/bin/env ruby
require 'bunny'

# create connection
conn = Bunny.new(automatically_recover: true)
conn.start

# create channel
ch = conn.create_channel

# define an exclusive queue, bind to an exchange
x = ch.fanout('logs')
q = ch.queue('', exclusive: true)
q.bind(x)

# ch.prefetch(1);
puts ' [*] waiting for messages. To exit press Ctrl+C'

begin
  q.subscribe(manual_ack: true, block: true) do |_delivery_info, _properties, body|
    puts " [x] log received in Ruby: #{body}"
  end
rescue Interrupt => _exception
  puts ' [*] closing connection...'
  conn.close
  exit 0
end
