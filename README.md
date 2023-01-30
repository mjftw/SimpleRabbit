# SimpleRabbit

A little library on top of AMQP to simplify interacting with RabbitMQ.

Has functions to:

- Send messages
- Receive a single message
- Create a lazy message receive stream

## Playing locally

### RabbitMQ

To start a local RabbitMQ server with docker:

```sh
docker run -p 5672:5672 -p 15672:15672 rabbitmq:3.10.5-management
```

### The library

You can play with it using `iex -S mix`.

Try running a few IEx shells in parallel to test sending and receiving messages.

We'll send some messages from shell 1:

```elixir
iex(1)> SimpleRabbit.Send.send("Hello consumers!", "my_fun_channel")
:ok
iex(2)> SimpleRabbit.Send.send("Hello again", "my_fun_channel")
:ok
iex(3)> SimpleRabbit.Send.send("Hello again and again", "my_fun_channel")
:ok
iex(4)> SimpleRabbit.Send.send("Hello again and again and again", "my_fun_channel")
:ok
```

Read one message from shell 2:

```elixir
iex(1)> SimpleRabbit.Receive.one("my_fun_channel", "consumer1")
%SimpleRabbit.Message{
  payload: "Hello consumers!",
  meta: %{
    app_id: :undefined,
    cluster_id: :undefined,
    consumer_tag: "consumer1",
    content_encoding: :undefined,
    content_type: :undefined,
    correlation_id: :undefined,
    delivery_tag: 1,
    exchange: "",
    expiration: :undefined,
    headers: :undefined,
    message_id: :undefined,
    persistent: false,
    priority: :undefined,
    redelivered: false,
    reply_to: :undefined,
    routing_key: "my_fun_channel",
    timestamp: :undefined,
    type: :undefined,
    user_id: :undefined
  }
}
```

And work with a stream in shell 3:

```elixir
iex(1)> SimpleRabbit.Receive.stream("my_fun_channel", "consumer2") |>
...(1)>   Stream.map(&IO.inspect/1) |>
...(1)>   Stream.take(2) |>
...(1)>   Stream.run()
%SimpleRabbit.Message{
  payload: "Hello again",
  meta: %{
    app_id: :undefined,
    cluster_id: :undefined,
    consumer_tag: "consumer2",
    content_encoding: :undefined,
    content_type: :undefined,
    correlation_id: :undefined,
    delivery_tag: 1,
    exchange: "",
    expiration: :undefined,
    headers: :undefined,
    message_id: :undefined,
    persistent: false,
    priority: :undefined,
    redelivered: true,
    reply_to: :undefined,
    routing_key: "my_fun_channel",
    timestamp: :undefined,
    type: :undefined,
    user_id: :undefined
  }
}
%SimpleRabbit.Message{
  payload: "Hello again and again",
  meta: %{
    app_id: :undefined,
    cluster_id: :undefined,
    consumer_tag: "consumer2",
    content_encoding: :undefined,
    content_type: :undefined,
    correlation_id: :undefined,
    delivery_tag: 2,
    exchange: "",
    expiration: :undefined,
    headers: :undefined,
    message_id: :undefined,
    persistent: false,
    priority: :undefined,
    redelivered: true,
    reply_to: :undefined,
    routing_key: "my_fun_channel",
    timestamp: :undefined,
    type: :undefined,
    user_id: :undefined
  }
}
:ok
```
