defmodule Matchx.Matchbot.Client do
  alias Matchx.Matchbot.Client.Connection, as: Connection
  require Logger
  use GenServer

  @name __MODULE__
  # public API

  def start_link() do
    Logger.debug("HERE COMES THE CLIENT???")
    GenServer.start_link(__MODULE__, [], name: @name)
  end

  def receive(command, args) do
    GenServer.cast(@name, {command, args})
  end

  defp write(command, args) do
    Connection.write(command, args)
  end

  # callbacks

  def handle_cast({"LOGIN", stuff}, state) do
    write("yep ok LOGIN", [])
    {:noreply, state}
  end

  def handle_cast({msg, stuff}, state) do
    Logger.info("got an unknown command: #{inspect(msg)}")
    write(msg, [])
    {:noreply, state}
  end
end
