defmodule Telephony.Core.Pospaid do
  alias Telephony.Core.Call
  defstruct spent: 0
  @price_per_minte 1.04

  def make_call(subscriber, time_spent, date) do
    subscriber
    |> update_spent(time_spent)
    |> add_call(time_spent, date)
  end

  defp update_spent(%{subscriber_type: subscriber_type} = subscriber, time_spent) do
    spent = @price_per_minte * time_spent
    subscriber_type = %{subscriber_type | spent: subscriber_type.spent + spent}
    %{subscriber | subscriber_type: subscriber_type}
  end

  defp add_call(subscriber, time_spent, date) do
    call = Call.new(time_spent, date)
    %{subscriber | calls: subscriber.calls ++ [call]}
  end

  defimpl Invoice, for: Telephony.Core.Pospaid do
    def print(_pospaid, calls, year, month) do
      calls =
        Enum.reduce(calls, [], fn call, acc ->
          if call.date.year == year and call.date.month == month do
            value_spent = call.time_spent * 1.04
            call = %{date: call.date, time_spent: call.time_spent, value_spent: value_spent}

            acc ++ [call]
          else
            acc
          end
        end)

      value_spent = Enum.reduce(calls, 0, &(&1.value_spent + &2))

      %{
        value_spent: value_spent,
        calls: calls
      }
    end
  end
end
