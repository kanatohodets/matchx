defmodule Matchx.Matchbot do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [
      # TODO: global named processes or start link and stuff?
      worker(Matchx.Matchbot.Client.Protocol, [:client_protocol]),
      worker(Matchx.Matchbot.Client.Connection, [:client_connection]),
      worker(Matchx.Matchbot.Client, [:client])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
