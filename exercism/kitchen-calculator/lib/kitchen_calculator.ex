defmodule KitchenCalculator do
  def get_volume({_unit, volume}), do: volume

  def to_milliliter({unit, volume}) do
    conversion_factor =
      case unit do
        :cup -> 240
        :fluid_ounce -> 30
        :teaspoon -> 5
        :tablespoon -> 15
        :milliliter -> 1
      end

    {:milliliter, volume * conversion_factor}
  end

  def from_milliliter({:milliliter, volume}, unit) do
    conversion_factor =
      case unit do
        :cup -> 240
        :fluid_ounce -> 30
        :teaspoon -> 5
        :tablespoon -> 15
        :milliliter -> 1
      end

    {unit, volume / conversion_factor}
  end

  def convert(volume_pair, unit) do
    {_, volume} = to_milliliter(volume_pair)
    from_milliliter({:milliliter, volume}, unit)
  end
end
