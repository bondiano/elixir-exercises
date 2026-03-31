defmodule Hw2TramFsm do
  alias Hw2TramFsm.Impl.Tram
  alias Hw2TramFsm.Runtime.Server

  @type tram :: Server.t()

  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts \\ []) do
    Server.start_link(opts)
  end

  @spec status(tram) :: Tram.t()
  def status(pid), do: GenServer.call(pid, :status)

  @spec dispatch(tram) :: :ok | {:error, atom()}
  def dispatch(pid), do: GenServer.call(pid, :dispatch)

  @spec arrive(tram) :: :ok | {:error, atom()}
  def arrive(pid), do: GenServer.call(pid, :arrive)

  @spec depart(tram) :: :ok | {:error, atom()}
  def depart(pid), do: GenServer.call(pid, :depart)

  @spec turnaround(tram) :: :ok | {:error, atom()}
  def turnaround(pid), do: GenServer.call(pid, :turnaround)

  @spec arrive_at_terminus(tram) :: :ok | {:error, atom()}
  def arrive_at_terminus(pid), do: GenServer.call(pid, :arrive_at_terminus)

  @spec arrive_at_depot(tram) :: :ok | {:error, atom()}
  def arrive_at_depot(pid), do: GenServer.call(pid, :arrive_at_depot)

  @spec return_to_depot(tram) :: :ok | {:error, atom()}
  def return_to_depot(pid), do: GenServer.call(pid, :return_to_depot)

  @spec breakdown(tram) :: :ok | {:error, atom()}
  def breakdown(pid), do: GenServer.call(pid, :breakdown)

  @spec repair(tram) :: :ok | {:error, atom()}
  def repair(pid), do: GenServer.call(pid, :repair)

  @spec board(tram, pos_integer()) :: :ok | {:error, atom()}
  def board(pid, count), do: GenServer.call(pid, {:board, count})

  @spec alight(tram, pos_integer()) :: :ok | {:error, atom()}
  def alight(pid, count), do: GenServer.call(pid, {:alight, count})
end
