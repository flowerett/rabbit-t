defmodule FibServer do
  def fib(0), do: 0
  def fib(1), do: 1
  def fib(n) when n > 1, do: fib(n-1) + fib(n-2)

  def wait_for_messages(channel) do
    receive do
      {:basic_deliver, payload, meta} ->
        {n, _} = Integer.parse(payload)
        st = Time.utc_now
        IO.puts " [.] calculating fib(#{n})..."
        response = fib(n)
        IO.puts " [.] sending result: #{response}, spent: #{Time.diff(Time.utc_now, st, :microsecond)/1000000}"

        AMQP.Basic.publish(
          channel,
          "",
          meta.reply_to,
          "#{response}",
          correlation_id: meta.correlation_id
        )
        AMQP.Basic.ack(channel, meta.delivery_tag)

        wait_for_messages(channel)
    end
  end
end

# create connection
{:ok, connection} = AMQP.Connection.open
{:ok, channel} = AMQP.Channel.open(connection)

# create channel
AMQP.Queue.declare(channel, "rpc_queue")

# subscribe to messages from queue
AMQP.Basic.qos(channel, prefetch_count: 1)
AMQP.Basic.consume(channel, "rpc_queue")
IO.puts " [x] Awaiting RPC requests"

FibServer.wait_for_messages(channel)
