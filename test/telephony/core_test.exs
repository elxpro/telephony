defmodule Telephony.CoreTest do
  use ExUnit.Case
  alias Telephony.Core
  alias Telephony.Core.Prepaid
  alias Telephony.Core.Subscriber

  setup do
    subscribers = [
      %Subscriber{
        full_name: "Gustavo",
        phone_number: "123",
        type: %Prepaid{credits: 0, recharges: []}
      }
    ]

    payload = %{
      full_name: "Gustavo",
      phone_number: "123",
      type: :prepaid
    }

    %{subscribers: subscribers, payload: payload}
  end

  test "create new subscriber", %{payload: payload} do
    subscribers = []
    result = Core.create_subscriber(subscribers, payload)

    expect = [
      %Subscriber{
        full_name: "Gustavo",
        phone_number: "123",
        type: %Prepaid{credits: 0, recharges: []}
      }
    ]

    assert expect == result
  end

  test "create a new subscriber", %{subscribers: subscribers} do
    payload = %{
      full_name: "Joe",
      phone_number: "1234",
      type: :prepaid
    }

    result = Core.create_subscriber(subscribers, payload)

    expect = [
      %Subscriber{
        full_name: "Gustavo",
        phone_number: "123",
        type: %Prepaid{credits: 0, recharges: []}
      },
      %Subscriber{
        full_name: "Joe",
        phone_number: "1234",
        type: %Prepaid{credits: 0, recharges: []}
      }
    ]

    assert expect == result
  end

  test "display error, when subscriber already exist", %{
    subscribers: subscribers,
    payload: payload
  } do
    result = Core.create_subscriber(subscribers, payload)
    assert {:error, "Subscriber `123`, already exist"} == result
  end

  test "display error, when type does not exist", %{payload: payload} do
    payload = Map.put(payload, :type, :safasfsadf)
    result = Core.create_subscriber([], payload)
    assert {:error, "Only 'prepaid' or 'postpaid' are accepted"} == result
  end
end
