defmodule BoutiqueSuggestions do
  def get_combinations(tops, bottoms, options \\ []) do
    for top <- tops,
        bottom <- bottoms,
        top.base_color != bottom.base_color and
          top.price + bottom.price <= Keyword.get(options, :maximum_price, 100.0),
        do: {top, bottom}
  end
end
