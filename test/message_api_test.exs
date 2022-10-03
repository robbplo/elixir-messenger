defmodule MessageApiTest do
  use ExUnit.Case

  test "it registers a new user" do

    {:ok, _} = Worker.start_link()

    assert is_number(MessageApi.register("Alex"))
  end

  test "it connects to a room" do
    {:ok, _} = Worker.start_link()
    client_id = MessageApi.register("Alex")

    assert :ok == MessageApi.subscribe(client_id, 1)
  end

  test "it retrieves room info" do

  end
end
