defmodule BotSupervisor do
  use Supervisor

  def start_link(args \\ []) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    children = [BotConsumer]

    Supervisor.init(children, strategy: :one_for_one)
  end
end

defmodule BotConsumer do
  use Nostrum.Consumer

  alias Nostrum.Api

  def start_link do
    Consumer.start_link(__MODULE__)
  end

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    author_is_bot =
      case msg.author.bot do
        true -> true
        _ -> false
      end

    mentions_me = Enum.any?(msg.mentions, fn m -> String.contains?(m.username, "Bobby B") end)

    if not author_is_bot and mentions_me do
      response = Enum.take_random(Data.quotes(), 1) |> Enum.at(0)
      Api.create_message!(msg.channel_id, response)
    end
  end

  def handle_event(_event) do
    :noop
  end
end
