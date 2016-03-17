defmodule Matchx.Matchbot.Client.Protocol do
  require Logger
  use GenServer

  @name __MODULE__
  # public API

  def start_link() do
    Logger.debug("HERE COMES THE protocol")
    GenServer.start_link(__MODULE__, [], name: @name)
  end

  def decode(msg) do
    Logger.debug(inspect("decode? #{msg}"))
    GenServer.call(@name, {:decode, msg})
  end

  def encode(command, args) do
    GenServer.call(@name, {:encode, command, args})
  end

  # callbacks

  def handle_call({:decode, msg}, _from, state) do
    Logger.debug(inspect("decoding a message: #{msg}"))
    msg = String.rstrip(msg)
    {:reply, {msg, []}, state}
  end

  def handle_call({:encode, command, args}, _from, state) do
    Logger.debug(inspect("encoding a message: #{command}"))
    {:reply, "you said: " <> command, state}
  end
end
