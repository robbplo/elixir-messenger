defmodule Worker do
  use GenServer

  # Callbacks

  @impl true
  def init(_stack) do
    {:ok, %WorkerState{rooms: %{1 => %RoomInfo{id: 1}}}}
  end

  @impl true
  def handle_call(:pop, _from, _state) do
    # {:reply, head, tail}
  end

  @impl true
  def handle_call({:register, name}, _from, %WorkerState{clients: clients} = state) do
    client = %Client{name: name, id: System.unique_integer([:positive])}
    new_clients = Map.put(clients, client.id, client)

    {:reply, client.id, %WorkerState{state | clients: new_clients}}
  end

  @impl true
  def handle_call(
        {:subscribe, {client_id, room_id}},
        from,
        %WorkerState{clients: clients, rooms: rooms} = state
      ) do
    room = rooms[room_id]
    client = clients[client_id]
    new_client = %Client{client | pid: from}
    new_room_clients = Map.put(room.clients, client_id, new_client)

    new_room = %RoomInfo{room | clients: new_room_clients}
    new_rooms = Map.put(rooms, room_id, new_room)

    room.clients
    |> Map.values()
    |> Enum.each(&Process.send(&1.pid, %Events.ClientConnected{client_id: client_id}, []))

    {:reply, :ok, %WorkerState{state | rooms: new_rooms}}
  end

  @impl true
  def handle_call({:get_room_info, room_id}, _, state) do
    {:reply, Map.get(state.rooms, room_id), state}
  end

  @impl true
  def handle_call({:send_message, {_body, _sender_id, room_id} = message}, _, state) do
    room = state.rooms[room_id]
    new_room = Map.put(room, :messages, [message | room.messages])
    new_state = %WorkerState{state | rooms: Map.put(state.rooms, room_id, new_room)}
    # TODO: use message struct
    # TODO: send message event to others in room

    {:reply, :ok, new_state}
  end

  def start_link() do
    {:ok, _pid} = GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end
end
