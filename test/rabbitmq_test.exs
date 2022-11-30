defmodule RabbitmqTest do
  use ExUnit.Case
  doctest Rabbitmq

  test "greets the world" do
    assert Rabbitmq.hello() == :world
  end
end
