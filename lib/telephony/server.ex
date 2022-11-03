defmodule Telephony.Server do
  @behaviour GenServer
  alias Telephony.Core

  def start_link(server_name) do
    GenServer.start_link(__MODULE__, [], name: server_name)
  end

  def init(subscribers), do: {:ok, subscribers}

  def handle_call({:create_subscriber, payload}, _, subcribers) do
    case Core.create_subscriber(subcribers, payload) do
      {:error, _} = err ->
        {:reply, err, subcribers}

      subcribers ->
        {:reply, subcribers, subcribers}
    end
  end
end
