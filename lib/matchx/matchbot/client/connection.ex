defmodule Matchx.Matchbot.Client.Connection do
  alias Matchx.Matchbot.Client.Protocol, as: Protocol
  alias Matchx.Matchbot.Client, as: Client
  require Logger
  use GenServer

  @name __MODULE__

  # public API

  # not start link because this is started by the client, and we want to
  # maintain the connection even if the client bombs
  def start(server_address, server_port) do
    Logger.debug("CONNECTION TIME #{inspect([server_address, server_port])}")
    GenServer.start(__MODULE__, [server_address, server_port], name: @name)
  end

  def write(msg, args) do
    Logger.debug("sending a message to socket: #{msg}")
    GenServer.call(@name, {:write, msg, args})
  end

  # callbacks

  def init([server_address, server_port]) when is_list(server_address) do
    opts = [:binary, active: true, packet: :line]
    case :gen_tcp.connect(server_address, server_port, opts) do
      {:ok, socket} ->
        {:ok, %{socket: socket, msg_id: 0}}
      {:error, error} ->
        {:stop, error}
    end
  end

  def init([server_address, server_port]) when is_binary(server_address) do
    server = String.to_char_list(server_address)
    init([server, server_port])
  end

  def handle_info({:tcp, socket, msg}, state) do
    { command, args } = Protocol.decode(msg)

    Client.receive(command, args)
    {:noreply, state}
  end

  def handle_info({:tcp_closed, port}, state) do
    {:stop, {:shutdown, :tcp_closed}, state}
  end


  def handle_call({:write, command, args}, _from, %{socket: socket, msg_id: current_msg_id} = state) do
    id = current_msg_id + 1
    encoded = Protocol.encode(command, id, args)
    :ok = :gen_tcp.send(socket, encoded)
    {:reply, :ok, %{state | msg_id: id}}
  end
end
