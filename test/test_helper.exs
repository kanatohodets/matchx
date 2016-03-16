ExUnit.start

Mix.Task.run "ecto.create", ~w(-r Matchx.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r Matchx.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(Matchx.Repo)

