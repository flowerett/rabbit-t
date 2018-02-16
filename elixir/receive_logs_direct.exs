defmodule ReceiveDirectLogs do
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

{severities, _, _} =
  System.argv
  |> OptionParser.parse(strict: [info: :boolean, warning: :boolean, error: :boolean])

# define queue and bind to exchange using routing keys
AMQP.Exchange.declare(channel, "direct_logs", :direct)
{:ok, %{queue: queue_name}} = AMQP.Queue.declare(channel, "", exclusive: true)

for {severity, true} <- severities do
  binding_key = severity |> to_string
  AMQP.Queue.bind(channel, queue_name, "direct_logs", routing_key: binding_key)
end

# subscribe to messages from queue
AMQP.Basic.consume(channel, queue_name, nil, no_ack: true)
IO.puts " [*] Waiting for messages. To exit press CTRL+C, CTRL+C"

ReceiveDirectLogs.wait_for_messages(channel)
