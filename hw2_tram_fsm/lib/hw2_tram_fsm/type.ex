defmodule Hw2TramFsm.Type do
  @type status ::
          :in_depot
          | :departing_depot
          | :at_station
          | :moving
          | :at_terminus
          | :broken_down
          | :returning_to_depot

  @type direction :: :forward | :backward

  @type route :: [String.t()]
end
