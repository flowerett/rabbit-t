{:ok, connection} = AMQP.Connection.open
{:ok, channel} = AMQP.Channel.open(connection)

AMQP.Queue.declare(channel, "hello")

AMQP.Basic.publish(channel, "", "hello", "Hello from Elixir")
IO.puts " [x] Sent a hello message"

AMQP.Connection.close(connection)
