defmodule BirdCount do
  def today(list) do
    List.first(list)
  end

  def increment_day_count(list) do
    case list do
      [] -> [1]
      [head | tail] -> [head + 1 | tail]
    end
  end

  def has_day_without_birds?(list) do
    case list do
      [] -> false
      [0 | _] -> true
      [_ | tail] -> has_day_without_birds?(tail)
    end
  end

  def total(list) do
    Enum.sum(list)
  end

  def busy_days(list) do
    case list do
      [] -> 0
      [head | tail] when head >= 5 -> 1 + busy_days(tail)
      [_ | tail] -> busy_days(tail)
    end
  end
end
