defmodule Matchx.Matchbot.Client do
  require Logger
  use GenServer

  @name __MODULE__
  # public API

  def start_link(name) do
    Logger.debug("HERE COMES THE CLIENT???")
    GenServer.start_link(__MODULE__, [])
  end

  def receive(command, args) do
    GenServer.cast(@name, command, args)
  end

  def send(command) do

  end

  # callbacks

  def handle_info({:login, user, pass}, state) do
  end
end
