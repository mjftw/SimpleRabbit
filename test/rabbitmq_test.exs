defmodule SimpleRabbitTest do
  use ExUnit.Case
  doctest SimpleRabbit

  test "greets the world" do
    assert SimpleRabbit.hello() == :world
  end
end
