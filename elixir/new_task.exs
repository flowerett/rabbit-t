# create connection
{:ok, connection} = AMQP.Connection.open
{:ok, channel} = AMQP.Channel.open(connection)

# create channel
AMQP.Queue.declare(channel, "task_queue", durable: true)

# get message
message =
  case System.argv do
    []    -> "Hello from Elixir task..."
    words -> Enum.join(words, " ")
  end

# send message
AMQP.Basic.publish(channel, "", "task_queue", message, persistent: true)
IO.puts " [x] Send '#{message}'"

AMQP.Connection.close(connection)
