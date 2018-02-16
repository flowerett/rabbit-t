defmodule ReceiveLogs do
  def wait_for_messages(channel) do
    receive do
      {:basic_deliver, payload, _meta} ->
        IO.puts " [x] log received in Elixir: #{payload}"

        wait_for_messages(channel)
    end
  end
end

# create connection
{:ok, connection} = AMQP.Connection.open
{:ok, channel} = AMQP.Channel.open(connection)

# define exchange and bind to it
AMQP.Exchange.declare(channel, "logs", :fanout)
{:ok, %{queue: queue_name}} = AMQP.Queue.declare(channel, "", exclusive: true)
AMQP.Queue.bind(channel, queue_name, "logs")

# subscribe to messages from queue
AMQP.Basic.consume(channel, queue_name, nil, no_ack: true)
IO.puts " [*] Waiting for messages. To exit press CTRL+C, CTRL+C"

ReceiveLogs.wait_for_messages(channel)
