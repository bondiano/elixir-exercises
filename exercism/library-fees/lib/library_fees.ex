defmodule LibraryFees do
  def datetime_from_string(string) do
    NaiveDateTime.from_iso8601!(string)
  end

  @spec before_noon?(NaiveDateTime.t()) :: boolean()
  def before_noon?(datetime) do
    datetime.hour < 12
  end

  def return_date(%{year: year, month: month, day: day} = checkout_datetime) do
    checkout_date = Date.new!(year, month, day)

    if before_noon?(checkout_datetime) do
      Date.add(checkout_date, 28)
    else
      Date.add(checkout_date, 29)
    end
  end

  def days_late(planned_return_date, actual_return_datetime) do
    actual_return_datetime
    |> Date.diff(planned_return_date)
    |> max(0)
  end

  def monday?(%{year: year, month: month, day: day}) do
    Date.day_of_week(Date.new!(year, month, day)) == 1
  end

  def calculate_late_fee(checkout, return, rate) do
    checkout_datetime = datetime_from_string(checkout)
    return_datetime = datetime_from_string(return)
    raw_fee = days_late(return_date(checkout_datetime), return_datetime) * rate

    if monday?(return_datetime) do
      floor(raw_fee * 0.5)
    else
      raw_fee
    end
  end
end
