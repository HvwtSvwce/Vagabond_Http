defmodule VagabondHttp.Listener do
  require Logger
  require :inet

  @options [:binary, packet: :line, active: :false, reuseaddr: true]

  @router VagabondHttp.Router

  def start_link() do
    {:ok, listener} = :gen_tcp.listen(80, @options)

    Logger.notice("Server listening on port 80")

    pid = spawn(fn -> loop(listener, self()) end)



    {:ok, pid}
  end

  def loop(listener, pid) do
    {:ok, socket} = :gen_tcp.accept(listener)

    client = :inet.peername(socket)

    Task.Supervisor.start_child(VagabondHttp.Server.Supervisor, VagabondHttp.Server, :serve, [socket, client, @router])

    loop(listener, pid)
  end
end
