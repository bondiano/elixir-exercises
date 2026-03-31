defmodule Hw2TramFsmTest do
  use ExUnit.Case, async: true

  @route ["Depot", "Station A", "Station B", "Station C", "Terminus"]

  setup do
    {:ok, pid} = Hw2TramFsm.start_link(route: @route)
    %{tram: pid}
  end

  describe "init" do
    test "starts in :in_depot state", %{tram: tram} do
      state = Hw2TramFsm.status(tram)
      assert %Hw2TramFsm.Impl.Tram{} = state
      assert state.status == :in_depot
      assert state.route == @route
      assert state.passengers == 0
    end

    test "rejects route with less than 2 stations" do
      assert {:error, _} = Hw2TramFsm.start_link(route: ["Only One"])
    end

    test "rejects empty route" do
      assert {:error, _} = Hw2TramFsm.start_link(route: [])
    end
  end

  describe "dispatch" do
    test "transitions from :in_depot to :departing_depot", %{tram: tram} do
      assert :ok = Hw2TramFsm.dispatch(tram)
      assert Hw2TramFsm.status(tram).status == :departing_depot
    end

    test "fails when not in depot", %{tram: tram} do
      :ok = Hw2TramFsm.dispatch(tram)
      assert {:error, :invalid_transition} = Hw2TramFsm.dispatch(tram)
    end
  end

  describe "full route traversal" do
    test "depot -> first station -> moving -> next station", %{tram: tram} do
      :ok = Hw2TramFsm.dispatch(tram)
      :ok = Hw2TramFsm.arrive(tram)

      state = Hw2TramFsm.status(tram)
      assert state.status == :at_station
      assert state.current_station_index == 0

      :ok = Hw2TramFsm.depart(tram)
      assert Hw2TramFsm.status(tram).status == :moving

      :ok = Hw2TramFsm.arrive(tram)
      state = Hw2TramFsm.status(tram)
      assert state.status == :at_station
      assert state.current_station_index == 1
    end

    test "arrives at terminus at last station", %{tram: tram} do
      drive_to_terminus(tram)

      assert Hw2TramFsm.status(tram).status == :at_terminus
      assert Hw2TramFsm.status(tram).current_station_index == length(@route) - 1
    end

    test "turnaround at terminus reverses direction", %{tram: tram} do
      drive_to_terminus(tram)

      :ok = Hw2TramFsm.turnaround(tram)
      state = Hw2TramFsm.status(tram)
      assert state.status == :moving
      assert state.direction == :backward
    end

    test "full round trip back to first terminus", %{tram: tram} do
      drive_to_terminus(tram)
      :ok = Hw2TramFsm.turnaround(tram)

      # After turnaround tram is :moving backward from last station
      for _ <- 1..(length(@route) - 2) do
        :ok = Hw2TramFsm.arrive(tram)
        :ok = Hw2TramFsm.depart(tram)
      end

      # Final arrival at index 0 = terminus
      :ok = Hw2TramFsm.arrive_at_terminus(tram)
      assert Hw2TramFsm.status(tram).status == :at_terminus
      assert Hw2TramFsm.status(tram).current_station_index == 0
    end
  end

  describe "return to depot" do
    test "from terminus with no passengers", %{tram: tram} do
      drive_to_terminus(tram)

      :ok = Hw2TramFsm.return_to_depot(tram)
      assert Hw2TramFsm.status(tram).status == :returning_to_depot

      :ok = Hw2TramFsm.arrive_at_depot(tram)
      state = Hw2TramFsm.status(tram)
      assert state.status == :in_depot
      assert state.direction == :forward
    end

    test "fails from terminus with passengers", %{tram: tram} do
      :ok = Hw2TramFsm.dispatch(tram)
      :ok = Hw2TramFsm.arrive(tram)
      :ok = Hw2TramFsm.board(tram, 5)

      for _ <- 1..(length(@route) - 2) do
        :ok = Hw2TramFsm.depart(tram)
        :ok = Hw2TramFsm.arrive(tram)
      end

      :ok = Hw2TramFsm.depart(tram)
      :ok = Hw2TramFsm.arrive_at_terminus(tram)

      assert {:error, :passengers_on_board} = Hw2TramFsm.return_to_depot(tram)
    end

    test "fails when not at terminus", %{tram: tram} do
      assert {:error, :invalid_transition} = Hw2TramFsm.return_to_depot(tram)
    end
  end

  describe "passengers" do
    test "board passengers at station", %{tram: tram} do
      :ok = Hw2TramFsm.dispatch(tram)
      :ok = Hw2TramFsm.arrive(tram)
      :ok = Hw2TramFsm.board(tram, 10)
      assert Hw2TramFsm.status(tram).passengers == 10
    end

    test "alight passengers at station", %{tram: tram} do
      :ok = Hw2TramFsm.dispatch(tram)
      :ok = Hw2TramFsm.arrive(tram)
      :ok = Hw2TramFsm.board(tram, 10)
      :ok = Hw2TramFsm.alight(tram, 3)
      assert Hw2TramFsm.status(tram).passengers == 7
    end

    test "cannot alight more than on board", %{tram: tram} do
      :ok = Hw2TramFsm.dispatch(tram)
      :ok = Hw2TramFsm.arrive(tram)
      :ok = Hw2TramFsm.board(tram, 5)
      assert {:error, :not_enough_passengers} = Hw2TramFsm.alight(tram, 10)
    end

    test "cannot board while moving", %{tram: tram} do
      :ok = Hw2TramFsm.dispatch(tram)
      :ok = Hw2TramFsm.arrive(tram)
      :ok = Hw2TramFsm.depart(tram)
      assert {:error, :not_at_station} = Hw2TramFsm.board(tram, 5)
    end

    test "cannot alight while moving", %{tram: tram} do
      :ok = Hw2TramFsm.dispatch(tram)
      :ok = Hw2TramFsm.arrive(tram)
      :ok = Hw2TramFsm.board(tram, 10)
      :ok = Hw2TramFsm.depart(tram)
      assert {:error, :not_at_station} = Hw2TramFsm.alight(tram, 5)
    end
  end

  describe "breakdown" do
    test "while moving", %{tram: tram} do
      :ok = Hw2TramFsm.dispatch(tram)
      :ok = Hw2TramFsm.arrive(tram)
      :ok = Hw2TramFsm.depart(tram)
      :ok = Hw2TramFsm.breakdown(tram)
      assert Hw2TramFsm.status(tram).status == :broken_down
    end

    test "at station", %{tram: tram} do
      :ok = Hw2TramFsm.dispatch(tram)
      :ok = Hw2TramFsm.arrive(tram)
      :ok = Hw2TramFsm.breakdown(tram)
      assert Hw2TramFsm.status(tram).status == :broken_down
    end

    test "cannot break down while in depot", %{tram: tram} do
      assert {:error, :invalid_transition} = Hw2TramFsm.breakdown(tram)
    end

    test "repair sends tram to returning_to_depot", %{tram: tram} do
      :ok = Hw2TramFsm.dispatch(tram)
      :ok = Hw2TramFsm.arrive(tram)
      :ok = Hw2TramFsm.board(tram, 20)
      :ok = Hw2TramFsm.depart(tram)
      :ok = Hw2TramFsm.breakdown(tram)
      :ok = Hw2TramFsm.repair(tram)

      state = Hw2TramFsm.status(tram)
      assert state.status == :returning_to_depot
      assert state.passengers == 0
    end

    test "repair -> arrive completes return to depot", %{tram: tram} do
      :ok = Hw2TramFsm.dispatch(tram)
      :ok = Hw2TramFsm.arrive(tram)
      :ok = Hw2TramFsm.depart(tram)
      :ok = Hw2TramFsm.breakdown(tram)
      :ok = Hw2TramFsm.repair(tram)
      :ok = Hw2TramFsm.arrive_at_depot(tram)
      assert Hw2TramFsm.status(tram).status == :in_depot
    end
  end

  describe "invalid transitions" do
    test "cannot depart from depot", %{tram: tram} do
      assert {:error, :invalid_transition} = Hw2TramFsm.depart(tram)
    end

    test "cannot arrive while in depot", %{tram: tram} do
      assert {:error, :invalid_transition} = Hw2TramFsm.arrive(tram)
    end

    test "cannot turnaround while not at terminus", %{tram: tram} do
      :ok = Hw2TramFsm.dispatch(tram)
      :ok = Hw2TramFsm.arrive(tram)
      assert {:error, :invalid_transition} = Hw2TramFsm.turnaround(tram)
    end

    test "cannot dispatch twice", %{tram: tram} do
      :ok = Hw2TramFsm.dispatch(tram)
      assert {:error, :invalid_transition} = Hw2TramFsm.dispatch(tram)
    end
  end

  defp drive_to_terminus(tram) do
    :ok = Hw2TramFsm.dispatch(tram)
    :ok = Hw2TramFsm.arrive(tram)

    # Intermediate stations
    for _ <- 1..(length(@route) - 2) do
      :ok = Hw2TramFsm.depart(tram)
      :ok = Hw2TramFsm.arrive(tram)
    end

    # Last depart + arrive at terminus
    :ok = Hw2TramFsm.depart(tram)
    :ok = Hw2TramFsm.arrive_at_terminus(tram)
  end
end
