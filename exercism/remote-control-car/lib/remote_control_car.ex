defmodule RemoteControlCar do
  @enforce_keys [:nickname]
  defstruct [:nickname, :battery_percentage, :distance_driven_in_meters]

  def new(name \\ "none") do
    %RemoteControlCar{nickname: name, battery_percentage: 100, distance_driven_in_meters: 0}
  end

  def display_distance(%RemoteControlCar{distance_driven_in_meters: distance}) do
    "#{distance} meters"
  end

  def display_battery(%RemoteControlCar{battery_percentage: 0}), do: "Battery empty"

  def display_battery(%RemoteControlCar{battery_percentage: percentage}) do
    "Battery at #{percentage}%"
  end

  def drive(%RemoteControlCar{battery_percentage: 0} = remote_car), do: remote_car

  def drive(
        %RemoteControlCar{
          distance_driven_in_meters: distance,
          battery_percentage: percentage
        } = remote_car
      ) do
    %RemoteControlCar{
      remote_car
      | distance_driven_in_meters: distance + 20,
        battery_percentage: percentage - 1
    }
  end
end
