defmodule VagabondHttp do
  use Application



  def start(_type, _opts) do

    # router = VagabondHttp.Router
    # IO.puts("yeah")
    children = [
      {Task.Supervisor, name: VagabondHttp.Server.Supervisor},
      %{id: VagabondHttp.Listener, start: {VagabondHttp.Listener, :start_link, []}}
      # {VagabondHttp.Listener, router: router}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end

end
