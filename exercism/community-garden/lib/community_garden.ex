# Use the Plot struct as it is provided
defmodule Plot do
  @enforce_keys [:plot_id, :registered_to]
  defstruct [:plot_id, :registered_to]
end

defmodule CommunityGarden do
  def start() do
    Agent.start_link(fn -> {0, []} end)
  end

  def list_registrations(pid) do
    Agent.get(pid, fn {_, state} -> state end)
  end

  def register(pid, register_to) do
    Agent.get_and_update(pid, fn {id, state} ->
      plot = %Plot{plot_id: id + 1, registered_to: register_to}
      {plot, {id + 1, [plot | state]}}
    end)
  end

  def release(pid, plot_id) do
    Agent.update(pid, fn {id, state} ->
      {id, Enum.reject(state, fn plot -> plot.plot_id == plot_id end)}
    end)
  end

  def get_registration(pid, plot_id) do
    case Agent.get(pid, fn {_, state} ->
           List.first(Enum.filter(state, &(&1.plot_id == plot_id)))
         end) do
      nil -> {:not_found, "plot is unregistered"}
      plot -> plot
    end
  end
end
