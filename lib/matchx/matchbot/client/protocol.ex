defmodule Matchx.Matchbot.Client.Protocol do
  require Logger
  use GenServer

  @name __MODULE__
  # public API

  def start_link(name) do
    Logger.debug("HERE COMES THE protocol")
    GenServer.start_link(__MODULE__, [], name: @name)
  end

  def decode(msg) do
    Logger.debug(inspect("decode? #{msg}"))
    GenServer.call(@name, {:decode, msg})
  end

  def encode(pid, pieces) do
    GenServer.call(@name, {:encode, pieces})
  end

  # callbacks

  def handle_call({:decode, msg}, _from, state) do
    Logger.debug(inspect("decoding a message: #{msg}"))
    {:reply, msg, state}
  end

  def handle_call({:encode, msg}, _from, state) do
    {:reply, msg, state}
  end
end
