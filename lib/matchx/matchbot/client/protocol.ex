defmodule Matchx.Matchbot.Client.Protocol do
  require Logger
  use GenServer

  @initial_state %{}

  def start_link(name) do
    GenServer.start_link(__MODULE__, @initial_state, name: name)
  end

  def init(state) do
    {:ok, state}
  end

  def decode(msg) do
    Logger.debug(inspect("decode? #{msg}"))
    GenServer.call(:client_protocol, {:decode, msg})
  end

  def encode(pieces) do
    GenServer.call(:client_protocol, {:encode, pieces})
  end

  def handle_call({:decode, msg}, state) do
    Logger.debug(inspect("decoding a message: #{msg}"))
    {:reply, msg, state}
  end

  def handle_call({:encode, msg}, state) do
    {:reply, msg, state}
  end
end
