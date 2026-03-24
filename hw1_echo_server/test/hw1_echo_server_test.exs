defmodule Hw1EchoServerTest do
  use ExUnit.Case
  doctest Hw1EchoServer

  test "greets the world" do
    assert Hw1EchoServer.hello() == :world
  end
end
