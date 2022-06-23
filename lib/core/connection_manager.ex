defmodule VagabondHttp.ConnectionManager.Bucket do
  use Agent

  def start_link do
    Agent.start_link(fn ->
      %{}
    end)
  end

  def get(bucket, key) do
    Agent.get(bucket, &Map.get(&1, key))
  end

  def put(bucket, key, value) do
    Agent.update(bucket, &Map.put(&1, key, value))
  end

  def delete(bucket, key) do
    Agent.get_and_update(bucket, &Map.pop(&1, key))
  end
end

defmodule VagabondHttp.ConnectionManager.Registry do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def lookup(connections, client) do
    GenServer.call(connections, {:find_connections, client})
  end

  def create_connection(connections, client) do
    GenServer.call(connections, {:add_connection, client})
  end



  @impl true
  def init(:ok) do
    {:ok, %{}}
  end

  @impl true
  def handle_call({:find_connection, client}, _from, connections) do
    {:reply, Map.fetch(connections, client), connections}
  end

  def handle_call({:get_headers, headers}, _from, requests) do

  end

  @impl true
  def handle_call({:add_connection, client}, _from, connections) do
    if Map.has_key?(connections, client) do
      {:reply, client}
    else
      {:ok, bucket} = VagabondHttp.ConnectionManager.Bucket.start_link()
      {:reply, Map.put(connections, client, bucket)}
    end
  end

end
