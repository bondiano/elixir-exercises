defmodule Hw2TramFsm.Impl.Tram do
  alias Hw2TramFsm.Type

  @type t :: %__MODULE__{
          status: Type.status(),
          route: Type.route(),
          current_station_index: non_neg_integer() | nil,
          direction: Type.direction(),
          passengers: non_neg_integer()
        }

  defstruct status: :in_depot,
            route: [],
            current_station_index: nil,
            direction: :forward,
            passengers: 0

  @spec new(Type.route()) :: {:ok, t()} | {:error, :invalid_route}
  def new(route) when is_list(route) and length(route) >= 2 do
    {:ok, %__MODULE__{route: route}}
  end

  def new(_), do: {:error, :invalid_route}

  @spec dispatch(t()) :: {:ok, t()} | {:error, atom()}
  def dispatch(%{status: :in_depot, route: route} = state) when length(route) >= 2 do
    {:ok, %{state | status: :departing_depot}}
  end

  def dispatch(_), do: {:error, :invalid_transition}

  @spec arrive(t()) :: {:ok, t()} | {:error, atom()}
  def arrive(%{status: :departing_depot} = state) do
    {:ok, %{state | status: :at_station, current_station_index: 0}}
  end

  def arrive(%{status: :moving} = state) do
    next_index = next_station_index(state)

    if terminus?(state.route, next_index) do
      {:error, :next_is_terminus}
    else
      {:ok, %{state | status: :at_station, current_station_index: next_index}}
    end
  end

  def arrive(_), do: {:error, :invalid_transition}

  @spec arrive_at_terminus(t()) :: {:ok, t()} | {:error, atom()}
  def arrive_at_terminus(%{status: :moving} = state) do
    next_index = next_station_index(state)

    if terminus?(state.route, next_index) do
      {:ok, %{state | status: :at_terminus, current_station_index: next_index}}
    else
      {:error, :not_at_terminus}
    end
  end

  def arrive_at_terminus(_), do: {:error, :invalid_transition}

  @spec arrive_at_depot(t()) :: {:ok, t()} | {:error, atom()}
  def arrive_at_depot(%{status: :returning_to_depot} = state) do
    {:ok, %{state | status: :in_depot, current_station_index: nil, direction: :forward}}
  end

  def arrive_at_depot(_), do: {:error, :invalid_transition}

  @spec depart(t()) :: {:ok, t()} | {:error, atom()}
  def depart(%{status: :at_station} = state) do
    {:ok, %{state | status: :moving}}
  end

  def depart(_), do: {:error, :invalid_transition}

  @spec turnaround(t()) :: {:ok, t()} | {:error, atom()}
  def turnaround(%{status: :at_terminus} = state) do
    {:ok, %{state | status: :moving, direction: flip_direction(state.direction)}}
  end

  def turnaround(_), do: {:error, :invalid_transition}

  @spec return_to_depot(t()) :: {:ok, t()} | {:error, atom()}
  def return_to_depot(%{status: :at_terminus, passengers: 0} = state) do
    {:ok, %{state | status: :returning_to_depot, current_station_index: nil}}
  end

  def return_to_depot(%{status: :at_terminus}) do
    {:error, :passengers_on_board}
  end

  def return_to_depot(_), do: {:error, :invalid_transition}

  @spec breakdown(t()) :: {:ok, t()} | {:error, atom()}
  def breakdown(%{status: status} = state) when status in [:moving, :at_station] do
    {:ok, %{state | status: :broken_down}}
  end

  def breakdown(_), do: {:error, :invalid_transition}

  @spec repair(t()) :: {:ok, t()} | {:error, atom()}
  def repair(%{status: :broken_down} = state) do
    {:ok, %{state | status: :returning_to_depot, passengers: 0, current_station_index: nil}}
  end

  def repair(_), do: {:error, :invalid_transition}

  @spec board(t(), pos_integer()) :: {:ok, t()} | {:error, atom()}
  def board(%{status: :at_station, passengers: p} = state, count)
      when is_integer(count) and count > 0 do
    {:ok, %{state | passengers: p + count}}
  end

  def board(%{status: :at_station}, _), do: {:error, :invalid_count}
  def board(_, _), do: {:error, :not_at_station}

  @spec alight(t(), pos_integer()) :: {:ok, t()} | {:error, atom()}
  def alight(%{status: :at_station, passengers: p} = state, count)
      when is_integer(count) and count > 0 and count <= p do
    {:ok, %{state | passengers: p - count}}
  end

  def alight(%{status: :at_station, passengers: p}, count)
      when is_integer(count) and count > p do
    {:error, :not_enough_passengers}
  end

  def alight(%{status: :at_station}, _), do: {:error, :invalid_count}
  def alight(_, _), do: {:error, :not_at_station}

  defp next_station_index(%{current_station_index: i, direction: :forward}), do: i + 1
  defp next_station_index(%{current_station_index: i, direction: :backward}), do: i - 1

  defp terminus?(route, index), do: index == 0 or index == length(route) - 1

  defp flip_direction(:forward), do: :backward
  defp flip_direction(:backward), do: :forward
end
