# create connection
{:ok, connection} = AMQP.Connection.open
{:ok, channel} = AMQP.Channel.open(connection)

# get message and arguments
{severities, raw_message, _} =
  System.argv
  |> OptionParser.parse(strict: [info: :boolean, warning: :boolean, error: :boolean])
  |> case do
    {[], msg, _} -> {[info: true], msg, []}
    other -> other
  end

message =
  case raw_message do
    []    -> "Elixir log message..."
    words -> Enum.join(words, " ")
  end

# create exchange
AMQP.Exchange.declare(channel, "direct_logs", :direct)

# push a log message
for {severities, true} <- severities do
  severity = severities |> to_string
  AMQP.Basic.publish(channel, "direct_logs", severity, message)
  IO.puts " [x] Published '[#{severity}] #{message}'"
end


AMQP.Connection.close(connection)
