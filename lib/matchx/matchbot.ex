defmodule Matchx.Matchbot do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      worker(Matchx.Matchbot.Client.Protocol, []),
      worker(Matchx.Matchbot.Client, ["a", "foobar", 'localhost', 8200])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
