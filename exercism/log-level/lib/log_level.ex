defmodule LogLevel do
  def to_label(level, legacy?) do
    case level do
      0 when not legacy? -> :trace
      1 -> :debug
      2 -> :info
      3 -> :warning
      4 -> :error
      5 when not legacy? -> :fatal
      _ -> :unknown
    end
  end

  def alert_recipient(level, legacy?) do
    label = to_label(level, legacy?)

    cond do
      label in [:error, :fatal] -> :ops
      label == :unknown and legacy? -> :dev1
      label == :unknown -> :dev2
      true -> false
    end
  end
end
