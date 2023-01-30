defmodule SimpleRabbit.Send do
  def send(message, queue_name, exchange_name \\ "", publish_ops \\ []) do
    with {:ok, connection} <- AMQP.Connection.open(),
         {:ok, channel} <- AMQP.Channel.open(connection),
         {:ok, _queue} <- AMQP.Queue.declare(channel, queue_name),
         :ok <- AMQP.Basic.publish(channel, exchange_name, queue_name, message, publish_ops),
         :ok <- AMQP.Connection.close(connection),
         do: :ok
  end
end
