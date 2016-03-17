defmodule Matchx.Matchbot.Client.Connection do
  alias Matchx.Matchbot.Client.Protocol, as: Protocol
  alias Matchx.Matchbot.Client, as: Client
  require Logger
  use GenServer

  @name __MODULE__

  # public API

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: @name)
  end

  def write(msg, args) do
    Logger.debug("sending a message to socket: #{msg}")
    GenServer.call(@name, {:write, msg, args})
  end

  # callbacks

  def init(args) do
    opts = [:binary, active: true, packet: :line]
    {:ok, socket} = :gen_tcp.connect('localhost', 8500, opts)
    {:ok, %{socket: socket, msg_id: 0}}
  end

  def handle_info({:tcp, socket, msg}, state) do
    { command, args } = Protocol.decode(msg)

    Client.receive(command, args)
    {:noreply, state}
  end

  def handle_call({:write, command, args}, _from, %{socket: socket} = state) do
    encoded = Protocol.encode(command, args)
    :ok = :gen_tcp.send(socket, "#{state.msg_id} " <> encoded <> "\n")
    {:reply, :ok, %{state | msg_id: state.msg_id + 1}}
  end
end
