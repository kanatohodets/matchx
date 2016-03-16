defmodule Matchx.Matchbot.Client do
  require Logger
  use GenServer

  def start_link() do
    connection = GenServer.start_link(Matchx.Matchbot.Client.Connection, []) 
    GenServer.start_link(__MODULE__, %{connection: connection})
  end

  def handle_info({:login, user, pass}, state) do
    
  end
end
