defmodule Matchx.Matchbot.Client do
  alias Matchx.Matchbot.Client.Connection, as: Conn
  require Logger
  use GenServer

  @name __MODULE__
  @startup_delay 10
  @reconnect_delay 5000
  # public API

  def start_link(user, password, host, port) do
    Logger.debug("HERE COMES THE CLIENT???")
    pass_hash = :erlang.md5(password)
                |> :base64.encode

    GenServer.start_link(__MODULE__, [user, pass_hash, host, port], name: @name)
  end

  def init([user, pass_hash, host, port]) do
    :timer.send_after(@startup_delay, :start)
    {:ok, %{
        status: :disconnected,
        user: user,
        password_hash: pass_hash,
        host: host,
        port: port,
        ping_timer: nil,
        conn_monitor: nil,
    }}
  end

  def receive(command, args) do
    GenServer.cast(@name, {command, args})
  end

  def login(user, pass_hash) do
    Conn.write("LOGIN", [
      user, pass_hash, "3200", "*", "Matchbox", "0", "sp cl p"
    ])
  end

  # callbacks

  def handle_cast(message, %{status: :disconnected} = state) do
    Logger.warn("cannot handle #{inspect(message)} because I'm disconnected")
    {:noreply, state}
  end

  def handle_cast({"JOINQUEUEREQUEST", stuff}, state) do
    # Matchx.Matchbot.Matchmaker.join_queue_request
    Logger.debug("JOINQUEUEREUEST RECEIVED")
    {:noreply, state}
  end

  def handle_cast({"QUEUELEFT", stuff}, state) do
    # Matchx.Matchbot.Matchmaker.queue_left
    {:noreply, state}
  end

  def handle_cast({"REMOVEUSER", stuff}, state) do
    # Matchx.Matchbot.Matchmaker.remove_user
    {:noreply, state}
  end

  def handle_cast({"READYCHECKRESPONSE", stuff}, state) do
    # Matchx.Matchbot.Matchmaker.ready_check_response
    Logger.info("yep ok READYCHECKRESPONSE")
    {:noreply, state}
  end

  def handle_cast({"LOGININFOEND", stuff}, %{status: :disconnected} = state) do
    Logger.info("yep ok LOGININFOEND")
    {:noreply, %{state | status: :connected}}
  end

  def handle_cast({"PONG", stuff}, %{status: :disconnected} = state) do
    Logger.info("yep ok PONG")
    {:noreply, %{state | status: :connected}}
  end

  def handle_cast({"MOTD", line}, state) do
    Logger.info("MOTD line #{line}")
    {:noreply, state}
  end

  def handle_cast({msg, param_string}, state) do
    Logger.info("got an unknown command: #{inspect([msg, param_string])}")
    {:noreply, state}
  end

  def handle_info(:ping, state) do
    Conn.write("PING", [])
    {:noreply, state}
  end

  def handle_info(:start, %{host: host, port: port, user: user, password_hash: pass} = state) do
    started = case Conn.start(host, port) do
      {:ok, pid} ->
        :ok = login(user, pass)
        pid
      {:error, {:already_started, pid}} ->
        pid
      {:error, other_error} ->
        other_error
    end

    case started do
      pid when is_pid(started) ->
        monitor = Process.monitor(pid)
        {:ok, ping_timer} = :timer.send_interval(5000, :ping)
        {:noreply, %{state | conn_monitor: monitor, ping_timer: ping_timer, status: :connected}}

      error_case ->
        Logger.warn("Could not start connection: #{inspect(error_case)}")
        :timer.send_after(@reconnect_delay, :start)
        {:noreply, state}
    end
  end

  def handle_info({:DOWN, reference, :process, pid, reason}, %{ping_timer: ping_timer} = state) do
    Logger.warn("the connection went kablooie: #{inspect(reason)}")
    :timer.cancel(ping_timer)
    :timer.send_after(@reconnect_delay, :start)
    {:noreply, %{state | status: :disconnected, ping_timer: nil}}
  end

  # private
end
