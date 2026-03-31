defmodule Hw2TramFsm.Runtime.Server do
  use GenServer

  alias Hw2TramFsm.Impl.Tram

  @type t :: pid()

  def start_link(opts) do
    route = Keyword.get(opts, :route, [])
    name = Keyword.get(opts, :name)

    GenServer.start_link(__MODULE__, route, name: name)
  end

  @impl true
  def init(route) do
    case Tram.new(route) do
      {:ok, tram} -> {:ok, tram}
      {:error, reason} -> {:error, reason}
    end
  end

  @impl true
  def handle_call(:status, _from, tram) do
    {:reply, tram, tram}
  end

  def handle_call(action, _from, tram)
      when action in [
             :dispatch,
             :arrive,
             :arrive_at_terminus,
             :arrive_at_depot,
             :depart,
             :turnaround,
             :return_to_depot,
             :breakdown,
             :repair
           ] do
    case apply(Tram, action, [tram]) do
      {:ok, new_tram} -> {:reply, :ok, new_tram}
      {:error, _} = error -> {:reply, error, tram}
    end
  end

  def handle_call({:board, count}, _from, tram) do
    case Tram.board(tram, count) do
      {:ok, new_tram} -> {:reply, :ok, new_tram}
      {:error, _} = error -> {:reply, error, tram}
    end
  end

  def handle_call({:alight, count}, _from, tram) do
    case Tram.alight(tram, count) do
      {:ok, new_tram} -> {:reply, :ok, new_tram}
      {:error, _} = error -> {:reply, error, tram}
    end
  end

  def handle_call(_msg, _from, tram) do
    {:reply, {:error, :invalid_transition}, tram}
  end

  @impl true
  def handle_info(_msg, tram) do
    {:noreply, tram}
  end
end
