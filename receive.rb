#!/usr/bin/env ruby

require 'bunny'

conn = Bunny.new
conn.start

ch = conn.create_channel
q = ch.queue 'hello'

begin
  puts ' [*] waiting for messages. To exit press Ctrl+C'

  q.subscribe(block: true) do |_delivery_info, _properties, body|
    puts " [x] Received in Ruby receiver: #{body}"
  end
rescue Interrupt => _exception
  puts ' [*] closing connection...'
  conn.close
  exit 0
end
