defmodule MessageApi do
  @doc """
  Registers a new Client.
  """
  @spec register(String.t()) :: {:ok, %Client{}}
  def register(name) do
    GenServer.call(Worker, {:register, name})
  end

  @spec subscribe(pos_integer(), pos_integer()) :: pid()
  def subscribe(client_id, room_id) do
    GenServer.call(Worker, {:subscribe, {client_id, room_id}})
  end

  def get_room_info(room_id) do
    GenServer.call(Worker, {:get_room_info, room_id})
  end

  def send_message(body, sender_id, room_id) do
    GenServer.call(Worker, {:send_message, {body, sender_id, room_id}})
  end
end
