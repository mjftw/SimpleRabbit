defmodule Basic.Receive do
  alias Basic.Message

  @spec stream(any) ::
          ({:cont, any} | {:halt, any} | {:suspend, any}, any ->
             {:halted, any} | {:suspended, any, (any -> any)})
          | {:error, any}
  def stream(queue_name, connection_ops \\ [], consume_ops \\ []),
    do:
      Stream.resource(
        fn -> open_connection(queue_name, connection_ops, consume_ops) end,
        &stream_next/1,
        &close_connection/1
      )

  defp open_connection(queue_name, connection_ops, consume_ops) do
    with {:ok, connection} <- AMQP.Connection.open(connection_ops),
         {:ok, channel} <- AMQP.Channel.open(connection),
         {:ok, _queue} <- AMQP.Queue.declare(channel, queue_name),
         {:ok, _} <-
           AMQP.Basic.consume(
             channel,
             queue_name,
             self(),
             consume_ops
           ),
         do: {:ok, {connection, channel}}
  end

  defp close_connection({:ok, {connection, _channel}}), do: AMQP.Connection.close(connection)
  defp close_connection(error), do: {:error, error}

  defp stream_next({:ok, {connection, channel}}) do
    case(receive_message()) do
      {:ok, %Message{meta: %{delivery_tag: delivery_tag}} = message} ->
        AMQP.Basic.ack(channel, delivery_tag)
        {[message], {:ok, {connection, channel}}}

      {:error, error} ->
        {:halt, error}
    end
  end

  defp stream_next(error), do: {:halt, error}

  defp receive_message do
    receive do
      {:basic_deliver, payload, meta} ->
        {:ok, %Message{payload: payload, meta: meta}}

      {:basic_cancel, _, _} ->
        {:error, :connection_closed}
    end
  end
end
