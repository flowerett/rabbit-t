#!/usr/bin/env ruby
require 'bunny'

# create connection
conn = Bunny.new(automatically_recover: true)
conn.start

# create channel
ch = conn.create_channel

# define queue
q = ch.queue('task_queue', durable: true)

ch.prefetch(1);
puts ' [*] waiting for messages in "task_queue" To exit press Ctrl+C'

begin
  q.subscribe(manual_ack: true, block: true) do |delivery_info, _properties, body|
    puts " [x] Received in Ruby receiver: #{body}"

    sleep body.count('.').to_i

    puts ' [x] Job Done'
    ch.ack(delivery_info.delivery_tag)
  end
rescue Interrupt => _exception
  puts ' [*] closing connection...'
  conn.close
  exit 0
end
