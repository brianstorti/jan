defmodule Jan.GameSupervisor do
  use Supervisor

  @name Jan.GameSupervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: @name)
  end


  def start_game do
    Supervisor.start_child(@name, [])
  end

  def init(:ok) do
    children = [
      worker(Jan.GameServer, [])
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end
