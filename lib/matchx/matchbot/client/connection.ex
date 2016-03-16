defmodule Matchx.Matchbot.Client.Connection do
  require Logger
  use GenServer

  @initial_state %{socket: nil, msg_id: 0}

  def start_link() do
    GenServer.start_link(__MODULE__, @initial_state)
  end

  def init(state) do
    opts = [:binary, active: true, packet: :line]
    {:ok, socket} = :gen_tcp.connect('localhost', 8500, opts)
    {:ok, %{state | socket: socket}}
  end

  def handle_info({:tcp, socket, msg}, %{socket: socket} = state) do
    :gen_tcp.send(socket, "blorg you said #{msg}")
    {:ok,  decoded } = Matchx.Matchbot.Client.Protocol.decode(msg)
    {:noreply, state}
  end

  def handle_call({:write, msg}, %{socket: socket} = state) do
    :gen_tcp.send(socket, "#{state.msg_id} " <> msg)
    {:noreply, %{state | msg_id: state.msg_id + 1}}
  end
end
