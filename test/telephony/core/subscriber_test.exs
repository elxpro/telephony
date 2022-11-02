defmodule Telephony.Core.SubscriberTest do
  use ExUnit.Case
  alias Telephony.Core.{Pospaid, Prepaid, Subscriber, Call}

  test "create a subscriber" do
    # Given
    payload = %{
      full_name: "Gustavo",
      phone_number: "123",
      subscriber_type: :prepaid
    }

    # When
    result = Subscriber.new(payload)

    # then
    expected = %Subscriber{
      full_name: "Gustavo",
      phone_number: "123",
      subscriber_type: %Prepaid{credits: 0, recharges: []}
    }

    assert expected == result
  end

  test "create a pospaid subscriber" do
    payload = %{
      full_name: "Gustavo",
      phone_number: "123",
      subscriber_type: :pospaid
    }

    result = Subscriber.new(payload)

    expected = %Subscriber{
      full_name: "Gustavo",
      phone_number: "123",
      subscriber_type: %Pospaid{spent: 0}
    }

    assert expected == result
  end

  test "make a prepaid without credits call" do
    subscriber = %Subscriber{
      full_name: "Gustavo",
      phone_number: "123",
      subscriber_type: %Prepaid{credits: 0, recharges: []}
    }

    date = Date.utc_today()

    assert Subscriber.make_call(subscriber, 1, date) ==
             {:error, "Subscriber does not have credits"}
  end

  test "make a prepaid call" do
    subscriber = %Subscriber{
      full_name: "Gustavo",
      phone_number: "123",
      subscriber_type: %Prepaid{credits: 10, recharges: []}
    }

    date = Date.utc_today()

    assert Subscriber.make_call(subscriber, 1, date) ==
             %Subscriber{
               full_name: "Gustavo",
               phone_number: "123",
               subscriber_type: %Prepaid{credits: 8.55, recharges: []},
               calls: %Call{time_spent: 1, date: ~D[2022-11-02]}
             }
  end

  test "make a pospaid call" do
    subscriber = %Subscriber{
      full_name: "Gustavo",
      phone_number: "123",
      subscriber_type: %Pospaid{spent: 0}
    }

    date = Date.utc_today()

    assert Subscriber.make_call(subscriber, 1, date) ==
             %Subscriber{
               calls: %Call{
                 date: date,
                 time_spent: 1
               },
               full_name: "Gustavo",
               phone_number: "123",
               subscriber_type: %Pospaid{spent: 1.04}
             }
  end
end
