ExUnit.start

Mix.Task.run "ecto.create", ~w(-r Jan.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r Jan.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(Jan.Repo)

