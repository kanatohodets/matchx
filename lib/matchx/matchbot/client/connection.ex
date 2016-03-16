defmodule Matchx.Matchbot.Client.Connection do
  alias Matchx.Matchbot.Client.Protocol, as: Protocol
  require Logger
  use GenServer

  @name __MODULE__

  # public API

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: @name)
  end

  def send(msg) do
    GenServer.cast(@name, {:write, msg})
  end

  # callbacks

  def init(args) do
    opts = [:binary, active: true, packet: :line]
    {:ok, socket} = :gen_tcp.connect('localhost', 8500, opts)
    {:ok, %{socket: socket}}
  end

  def handle_info({:tcp, socket, msg}, %{socket: socket, protocol: protocol} = state) do
    decoded = Protocol.decode(msg)

    :gen_tcp.send(socket, "blorg you said #{msg}")
    Client.receive(decoded)
    {:noreply, state}
  end

  def handle_call({:write, msg}, %{socket: socket, protocol: protocol} = state) do
    encoded = Protocol.decode(msg)

    :gen_tcp.send(socket, "#{state.msg_id} " <> encoded)
    {:reply, %{state | msg_id: state.msg_id + 1}}
  end
end
