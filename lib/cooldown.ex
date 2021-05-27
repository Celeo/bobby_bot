defmodule Bot.ResponseCooldown do
  use GenServer
  require Logger

  @cooldown_by 300

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(_) do
    {:ok, Map.new()}
  end

  @impl true
  def handle_call({:get, guild_id}, _from, cooldowns) do
    {:reply, Map.get(cooldowns, guild_id, @cooldown_by), cooldowns}
  end

  @impl true
  def handle_call({:set, guild_id, new_count}, _from, cooldowns) do
    new_cooldowns = Map.put(cooldowns, guild_id, new_count)
    {:reply, :ok, new_cooldowns}
  end

  @impl true
  def handle_call({:decrement, guild_id}, _from, cooldowns) do
    current_count = Map.get(cooldowns, guild_id, @cooldown_by)
    {:reply, :ok, Map.put(cooldowns, guild_id, current_count - 1)}
  end

  def get(guild_id) do
    GenServer.call(__MODULE__, {:get, guild_id})
  end

  def decrement(guild_id) do
    GenServer.call(__MODULE__, {:decrement, guild_id})
  end

  def set_triggered(guild_id) do
    GenServer.call(__MODULE__, {:set, guild_id, @cooldown_by})
  end
end
