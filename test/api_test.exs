defmodule TelegramEx.APITest do
  use ExUnit.Case, async: false

  describe "long polling" do
    setup do
      Req.Test.stub(TelegramStub, fn conn ->
        conn = Plug.Conn.fetch_query_params(conn)

        assert conn.method == "GET"
        assert conn.query_params["timeout"] == "30"

        Req.Test.json(conn, %{
          "ok" => true,
          "result" => []
        })
      end)

      req_client =
        Req.new(plug: {Req.Test, TelegramStub})

      old_value = Application.get_env(:telegram_ex, :req_client)

      Application.put_env(:telegram_ex, :req_client, req_client)

      on_exit(fn ->
        if old_value do
          Application.put_env(:telegram_ex, :req_client, old_value)
        else
          Application.delete_env(:telegram_ex, :req_client)
        end
      end)

      :ok
    end

    test "uses a positive timeout for getUpdates" do
      assert {:ok, _updates} = TelegramEx.API.get_updates("test-token", 10)
    end
  end
end
