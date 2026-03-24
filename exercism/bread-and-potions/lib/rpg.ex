defmodule RPG do
  defprotocol Edible do
    def eat(item, character)
  end

  defmodule Character do
    defstruct health: 100, mana: 0
  end

  defmodule LoafOfBread do
    defstruct []

    defimpl Edible do
      def eat(%LoafOfBread{}, character) do
        {nil, %Character{character | health: character.health + 5}}
      end
    end
  end

  defmodule ManaPotion do
    defstruct strength: 10
  end

  defmodule Poison do
    defstruct []
  end

  defmodule EmptyBottle do
    defstruct []
  end

  defimpl Edible, for: ManaPotion do
    def eat(%ManaPotion{strength: strength}, character) do
      {%EmptyBottle{}, %Character{character | mana: character.mana + strength}}
    end
  end

  defimpl Edible, for: Poison do
    def eat(%Poison{}, character) do
      {%EmptyBottle{}, %Character{character | health: 0}}
    end
  end
end
