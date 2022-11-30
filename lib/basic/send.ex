defmodule Basic.Send do
  def send(channel, message) do
    with {:ok, connection} <- AMQP.Connection.open(),
         {:ok, channel} <- AMQP.Channel.open(connection),
         {:ok, _queue} <- AMQP.Queue.declare(channel, "hello"),
         :ok <- AMQP.Basic.publish(channel, "", "hello", message),
         :ok <- AMQP.Connection.close(connection),
         do: :ok
  end
end
