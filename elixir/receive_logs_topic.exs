defmodule ReceiveTopicLogs do
  def wait_for_messages(channel) do
    receive do
      {:basic_deliver, payload, meta} ->
        IO.puts " [x] [#{meta.routing_key}] received in Elixir: #{payload}"

        wait_for_messages(channel)
    end
  end
end

# create connection
{:ok, connection} = AMQP.Connection.open
{:ok, channel} = AMQP.Channel.open(connection)

# define queue and bind to exchange using routing keys
AMQP.Exchange.declare(channel, "topic_logs", :topic)
{:ok, %{queue: queue_name}} = AMQP.Queue.declare(channel, "", exclusive: true)

if length(System.argv) == 0 do
  IO.puts "Usage: mix run receive_logs_topic.exs [binding_key] ..."
  System.halt(1)
end

for binding_key <- System.argv do
  AMQP.Queue.bind(channel, queue_name, "topic_logs", routing_key: binding_key)
end

# subscribe to messages from queue
AMQP.Basic.consume(channel, queue_name, nil, no_ack: true)
IO.puts " [*] Waiting for messages. To exit press CTRL+C, CTRL+C"

ReceiveTopicLogs.wait_for_messages(channel)
