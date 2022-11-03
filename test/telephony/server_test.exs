defmodule Telephony.ServerTest do
  use ExUnit.Case
  alias Telephony.Server

  setup do
    {:ok, pid} = Server.start_link(:test)

    payload = %{
      full_name: "Gustavo",
      type: :prepaid,
      phone_number: "123"
    }

    %{pid: pid, process_name: :test, payload: payload}
  end

  test "check telephony subscribers state", %{pid: pid} do
    assert [] == :sys.get_state(pid)
  end

  test "create a subscriber", %{pid: pid, process_name: process_name, payload: payload} do
    old_state = :sys.get_state(pid)
    assert [] == old_state

    result = GenServer.call(process_name, {:create_subscriber, payload})
    refute old_state == result
  end

  test "error message when try to create a subscriber", %{
    pid: pid,
    process_name: process_name,
    payload: payload
  } do
    old_state = :sys.get_state(pid)
    assert [] == old_state

    GenServer.call(process_name, {:create_subscriber, payload})
    result = GenServer.call(process_name, {:create_subscriber, payload})
    assert {:error, "Subscriber `123`, already exist"} == result
  end

  test "search subscriber", %{process_name: process_name, payload: payload} do
    GenServer.call(process_name, {:create_subscriber, payload})
    result = GenServer.call(process_name, {:search_subscriber, payload.phone_number})
    assert result.full_name == payload.full_name
  end

  test "make recharge", %{pid: pid, process_name: process_name, payload: payload} do
    GenServer.call(process_name, {:create_subscriber, payload})

    date = Date.utc_today()
    state = :sys.get_state(pid)
    subscriber_state = hd(state)
    assert subscriber_state.type.recharges == []

    :ok = GenServer.cast(process_name, {:make_recharge, payload.phone_number, 100, date})

    state = :sys.get_state(pid)
    subscriber_state = hd(state)
    refute subscriber_state.type.recharges == []
  end
end
