defmodule MessageApi do
  @moduledoc """
  Documentation for `MessageServer`.
  """
  def register(name) do
    GenServer.call(Worker, {:register, name})
  end

  def subscribe(client_id, room_id) do
    GenServer.call(Worker, {:subscribe, {client_id, room_id}})
  end

  def get_room_info(room_id) do
    GenServer.call(Worker, {:get_room_info, room_id})
  end

  def send_message(body, sender_id, room_id) do
    GenServer.call(Worker, {:send_message, {body, sender_id, room_id}})
  end

  # connect(room_id, user_id) :: :ok
  # get_room_info(room_id) :: %RoomInfo{}
  # send_message(message, sender_id, recipient_id) :: :ok
end
