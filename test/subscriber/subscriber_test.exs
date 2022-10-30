defmodule Subscriber.SubscriberTest do
  use ExUnit.Case
  alias Subscriber.Subscriber

  test "create a subscriber" do
    # Given
    payload = %{
      full_name: "Gustavo",
      id: "123",
      phone_number: "123"
    }

    # When
    result = Subscriber.new(payload)

    # then
    expected = %Subscriber{
      full_name: "Gustavo",
      id: "123",
      phone_number: "123",
      subscriber_type: :prepaid
    }

    assert expected == result
  end
end
