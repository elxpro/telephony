defmodule Telephony.Core.PospaidTest do
  use ExUnit.Case
  alias Telephony.Core.{Call, Pospaid, Subscriber}

  setup do
    subscriber = %Subscriber{
      full_name: "Gustavo",
      phone_number: "123",
      subscriber_type: %Pospaid{spent: 0},
      calls: []
    }

    %{subscriber: subscriber}
  end

  test "make a call", %{subscriber: subscriber} do
    time_spent = 2
    date = NaiveDateTime.utc_now()
    result = Pospaid.make_call(subscriber, time_spent, date)

    expect = %Subscriber{
      full_name: "Gustavo",
      phone_number: "123",
      subscriber_type: %Pospaid{spent: 2.08},
      calls: [
        %Call{
          time_spent: 2,
          date: date
        }
      ]
    }

    assert expect == result
  end

  test "print invoice" do
    date = ~D[2022-11-01]
    last_month = ~D[2022-10-01]

    subscriber = %Subscriber{
      full_name: "Gustavo",
      phone_number: "123",
      subscriber_type: %Pospaid{spent: 90 * 1.04},
      calls: [
        %Call{
          time_spent: 10,
          date: date
        },
        %Call{
          time_spent: 50,
          date: last_month
        },
        %Call{
          time_spent: 30,
          date: last_month
        }
      ]
    }

    subscriber_type = subscriber.subscriber_type
    calls = subscriber.calls

    expect = %{
      value_spent: 80 * 1.04,
      calls: [
        %{
          time_spent: 50,
          value_spent: 50 * 1.04,
          date: last_month
        },
        %{
          time_spent: 30,
          value_spent: 30 * 1.04,
          date: last_month
        }
      ]
    }

    assert expect == Invoice.print(subscriber_type, calls, 2022, 10)
  end
end
