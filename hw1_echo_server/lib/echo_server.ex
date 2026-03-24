defmodule EchoServer do
  @moduledoc """
  A simple echo server that responds to :ping messages with {:pong, node()}.

  ## Usage

      iex> pid = EchoServer.start()
      iex> send(pid, {:ping, self()})
      iex> flush()
      {:pong, :nonode@nohost}
  """

  @doc """
  Starts the echo server process and returns its PID.
  """
  @spec start() :: pid()
  def start do
    spawn(__MODULE__, :loop, [])
  end

  @doc """
  Main receive loop. Listens for {:ping, sender} messages
  and responds with {:pong, node()}.
  """
  @spec loop() :: no_return()
  def loop do
    receive do
      {:ping, sender} when is_pid(sender) ->
        send(sender, {:pong, node()})
        loop()

      :stop ->
        :ok

      _other ->
        loop()
    end
  end
end
