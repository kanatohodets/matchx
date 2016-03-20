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

  def encode(command, id, args) do
    GenServer.call(@name, {:encode, command, id, args})
  end

  # callbacks

  def handle_call({:decode, "#" <> msg}, _from, state) do
    Logger.debug("<-- #{msg}")
    msg = String.rstrip(msg)
    # 24 PONG \n ... or 6734 QUEUELEFT {some json}
    case Regex.run(~r/(\d+) ([A-Z]+)\s?(.*)?$/, msg) do
      [_, id, command, param_string] ->
        {:reply, {command, param_string}, state}
      nil ->
        Logger.warn("parse error from server: #{inspect(msg)}")
        {:reply, {msg, []}, state}
    end
  end

  def handle_call({:decode, banner}, _from, state) do
    Logger.debug(inspect("got the banner#{banner}"))
    {:reply, {"banner", banner}, state}
  end

  def handle_call({:encode, command, id, args}, _from, state) do
    encoded_message = do_encode(command, id, args)
    Logger.debug(inspect("--> #{encoded_message}"))
    {:reply, encoded_message, state}
  end


  # private

  defp do_encode(command, id, []) do
    "##{id} #{command}  \n"
  end

  defp do_encode(command, id, args) do
    # tabs -> 2 spaces
    no_tabs = Enum.map(args, &( Regex.replace(~r/\t/, &1, "  ") ))

    sentence_wrapped = List.foldl(no_tabs, "", fn (param, param_string) ->
      case Regex.match?(~r/\s/, param) do
        # sentence: wrap in tabs
        true ->
          "#{param_string}\t#{param}\t"
        false ->
          stripped = String.rstrip(param_string)
          "#{param_string} #{param}"
      end
    end)

    final_param_string = String.strip(sentence_wrapped)
    "##{id} #{command} #{final_param_string}\n"
  end

end
