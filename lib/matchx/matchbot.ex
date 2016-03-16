defmodule Matchx.Matchbot do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [
      worker(Matchx.Matchbot.Client.Protocol, []),
      worker(Matchx.Matchbot.Client.Connection, []),
      worker(Matchx.Matchbot.Client, [])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
