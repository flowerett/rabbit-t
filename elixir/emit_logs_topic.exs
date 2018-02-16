# create connection
{:ok, connection} = AMQP.Connection.open
{:ok, channel} = AMQP.Channel.open(connection)

# get message and arguments
{topic, message} =
  System.argv
  |> case do
    [] -> {"anonimous.info", "Elixir message"}
    [message] -> {"anonimous.info", message}
    [topic|words] -> {topic, Enum.join(words, " ")}
  end

# create exchange
AMQP.Exchange.declare(channel, "topic_logs", :topic)

# push a log message
AMQP.Basic.publish(channel, "topic_logs", topic, message)
IO.puts " [x] Published from Elixir '[#{topic}] #{message}'"

AMQP.Connection.close(connection)
