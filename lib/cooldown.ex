defmodule Bot.ResponseCooldown do
  use GenServer
  require Logger

  @cooldown_by 500

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(_) do
    {:ok, @cooldown_by}
  end

  @impl true
  def handle_call(:get, _from, count) do
    {:reply, count, count}
  end

  @impl true
  def handle_call({:set, new_count}, _from, _count) do
    {:reply, :ok, new_count}
  end

  @impl true
  def handle_call(:decrement, _from, count) do
    new_count =
      case count do
        0 -> 0
        n -> n - 1
      end

    {:reply, :ok, new_count}
  end

  def get() do
    GenServer.call(__MODULE__, :get)
  end

  def decrement() do
    GenServer.call(__MODULE__, :decrement)
  end

  def set_triggered() do
    GenServer.call(__MODULE__, {:set, 200})
  end
end
