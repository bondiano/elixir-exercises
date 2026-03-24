defmodule NameBadge do
  def print(id, name, department) do
    department = if department == nil, do: "OWNER", else: String.upcase(department)

    if id do
      "[#{id}] - #{name} - #{department}"
    else
      "#{name} - #{department}"
    end
  end
end
