defmodule KV.Registry do
  use GenServer

  ##SERVER
  @doc """
  Inicia o registro
  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    names = %{}
    refs  = %{}
    {:ok, {names, refs}}
  end

  @impl true
  def handle_call({:lookup, name}, _from, state) do
    {names, _} = state
    {:reply, Map.fetch(names, name), state}
  end

  @impl true
  def handle_cast({:create, name}, {names, refs}) do
    if(Map.has_key?(names, name)) do
      {:noreply, {names, refs}}
    else
      {:ok, bucket} = KV.Bucket.start_link([])
      refs = Map.put(refs, Process.monitor(bucket), name)
      names = Map.put(names, name, bucket)
      {:noreply, {names, refs}}
    end
  end


  ##CLIENT

  @doc """
  Busca por um Bucket no registro
  """
  def lookup(server, name) do
    GenServer.call(server, {:lookup, name});
  end

  @doc """
  Chama, de forma assincrona, a criação de um novo bucket
  """
  def create(server, name) do
    GenServer.cast(server, {:create, name})
  end
end
