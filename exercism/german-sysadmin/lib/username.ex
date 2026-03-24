defmodule Username do
  def sanitize(username) do
    # ä becomes ae
    # ö becomes oe
    # ü becomes ue
    # ß becomes ss

    # fitlers non letter characters
    username
    |> Enum.flat_map(fn char ->
      case char do
        ?ä -> [?a, ?e]
        ?ö -> [?o, ?e]
        ?ü -> [?u, ?e]
        ?ß -> [?s, ?s]
        _ -> [char]
      end
    end)
    |> Enum.filter(fn char ->
      char in ?a..?z or char == ?_
    end)

    # Please implement the sanitize/1 function
  end
end
