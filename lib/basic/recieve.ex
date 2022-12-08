defmodule Basic.Receive do
  alias Basic.Message

  @spec stream(any) ::
          ({:cont, any} | {:halt, any} | {:suspend, any}, any ->
             {:halted, any} | {:suspended, any, (any -> any)})
          | {:error, any}
  def stream(queue_name) do
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
         do:
           Stream.repeatedly(fn ->
             receive do
               {:basic_deliver, payload, meta} -> %Message{payload: payload, meta: meta}
             end
           end)
  end

  def consume_with(queue_name, fun) do
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
         do: receive_loop(fun)
  end

  defp receive_loop(fun) do
    receive do
      {:basic_deliver, payload, _meta} ->
        fun.(payload)
        receive_loop(fun)
    end
  end
end
