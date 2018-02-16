# create connection
{:ok, connection} = AMQP.Connection.open
{:ok, channel} = AMQP.Channel.open(connection)

# get message
message =
  case System.argv do
    []    -> "Elixir log message..."
    words -> Enum.join(words, " ")
  end

# create exchange
AMQP.Exchange.declare(channel, "logs", :fanout)

# push a log message
AMQP.Basic.publish(channel, "logs", "", message)
IO.puts " [x] Published '#{message}'"

AMQP.Connection.close(connection)
