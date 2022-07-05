defmodule WorkerTest do
  use ExUnit.Case

  test "it handles register call" do
    assert {:reply, client_id, new_state} =
             Worker.handle_call({:register, "Alex"}, 123, %WorkerState{})

    assert is_number(client_id)
    assert %WorkerState{clients: %{^client_id => %Client{name: "Alex"}}} = new_state
  end

  test "it handles subscribe call" do
    client = %Client{id: 1, name: "Bob", pid: 123}
    room = %RoomInfo{id: 1, clients: %{2 => %Client{pid: self()}}}
    state = %WorkerState{clients: %{client.id => client}, rooms: %{room.id => room}}

    assert {:reply, :ok, new_state} =
             Worker.handle_call({:subscribe, {client.id, room.id}}, client.pid, state)

    assert %WorkerState{rooms: %{1 => %RoomInfo{clients: %{1 => ^client}}}} = new_state

    assert_receive %Events.ClientConnected{}
  end

  test "it handles get room info call" do
    room = %RoomInfo{id: 1, clients: %{1 => %Client{pid: self()}}}
    assert {:reply, room, %WorkerState{rooms: %{room.id => room}}}
  end

  test "it handles send message call" do
    clients = %{
      1 => recipient = %Client{pid: self(), name: "Bob"},
      2 => sender = %Client{pid: 123, name: "Alex"}
    }

    room = %RoomInfo{id: 1, clients: clients}
    state = %WorkerState{clients: clients, rooms: %{room.id => room}}
    message = {"Hello World!", sender.id, room.id}

    assert {:reply, :ok, new_state} =
             Worker.handle_call({:send_message, message}, sender.pid, state)

    assert %RoomInfo{messages: [message]} = new_state.rooms[room.id]
  end
end
