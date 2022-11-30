defmodule Basic.Receive do
  def for_each_message(fun) do
    receive do
      {:basic_deliver, payload, _meta} ->
        fun.(payload)
        for_each_message(fun)
    end
  end

  def consume(queue_name, fun) do
    with {:ok, connection} <- AMQP.Connection.open(),
         {:ok, channel} <- AMQP.Channel.open(connection),
         {:ok, _queue} <- AMQP.Queue.declare(channel, queue_name),
         {:ok, _} <-
           AMQP.Basic.consume(
             channel,
             queue_name,
             self(),
             no_ack: true
           ),
         do: for_each_message(fun)
  end
end
