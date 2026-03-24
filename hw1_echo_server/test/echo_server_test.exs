defmodule EchoServerTest do
  use ExUnit.Case, async: true

  describe "start/0" do
    test "returns a pid" do
      pid = EchoServer.start()
      assert is_pid(pid)
      assert Process.alive?(pid)
    end
  end

  describe "ping/pong" do
    test "responds with {:pong, node()} to {:ping, sender}" do
      pid = EchoServer.start()
      send(pid, {:ping, self()})
      assert_receive {:pong, node_name}
      assert node_name == node()
    end

    test "handles multiple pings" do
      pid = EchoServer.start()

      for _ <- 1..5 do
        send(pid, {:ping, self()})
      end

      for _ <- 1..5 do
        assert_receive {:pong, _}
      end
    end

    test "ignores unknown messages and stays alive" do
      pid = EchoServer.start()
      send(pid, :garbage)
      send(pid, {:ping, self()})
      assert_receive {:pong, _}
    end
  end

  describe "stop" do
    test "stops on :stop message" do
      pid = EchoServer.start()
      send(pid, :stop)
      Process.sleep(10)
      refute Process.alive?(pid)
    end
  end
end
