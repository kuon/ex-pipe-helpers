defmodule PipeHelpersTest do
  use ExUnit.Case
  doctest PipeHelpers, import: true
  import PipeHelpers

  test "ok" do
    assert "socket"
           |> ok() == {:ok, "socket"}
  end

  test "error" do
    assert :not_found
           |> err() == {:error, :not_found}
  end

  test "reply" do
    assert "state"
           |> reply("reply") == {:reply, "reply", "state"}
  end

  test "halt no reply" do
    assert "state"
           |> halt() == {:halt, "state"}
  end

  test "halt" do
    assert "state"
           |> halt("reply") == {:halt, "reply", "state"}
  end

  test "cont" do
    assert "state"
           |> cont() == {:cont, "state"}
  end

  test "rreply" do
    assert "reply"
           |> rreply("state") == {:reply, "reply", "state"}
  end

  test "noreply" do
    assert "state"
           |> noreply() == {:noreply, "state"}
  end

  test "pair" do
    assert "doe"
           |> pair(:jon) == {:jon, "doe"}
  end

  test "rpair" do
    assert "doe"
           |> rpair(:jon) == {"doe", :jon}
  end

  test "unpair" do
    assert {:jon, "doe"}
           |> unpair() == "doe"
  end

  test "unwrap" do
    assert {:ok, "hello"}
           |> unwrap!() == "hello"
  end

  test "unwrap error" do
    assert_raise MatchError, fn -> {:error, "hello"} |> unwrap!() end
  end

  test "tap_ok/match" do
    assert {:ok, "doe"}
           |> tap_ok(fn v ->
             send(self(), v)
           end) == {:ok, "doe"}

    assert_received "doe"
  end

  test "tap_ok/bypass" do
    assert {:error, "doe"}
           |> tap_ok(fn _v ->
             send(self(), :ignore)
           end) == {:error, "doe"}

    refute_received :ignore
  end

  test "tap_on/match" do
    assert :error
           |> tap_on(:error, fn v ->
             send(self(), v)
           end) == :error

    assert_received :error
  end

  test "tap_on/bypass" do
    assert {:ok, "doe"}
           |> tap_on(:error, fn _v ->
             send(self(), :ignore)
           end) == {:ok, "doe"}

    refute_received :ignore
  end

  test "then_ok/match" do
    assert {:ok, "doe"}
           |> then_ok(fn v ->
             send(self(), v)
             1
           end) == 1

    assert_received "doe"
  end

  test "then_ok/match nodata" do
    assert :ok
           |> then_ok(fn ->
             send(self(), "ok")
             1
           end) == 1

    assert_received "ok"
  end

  test "then_ok/bypass" do
    assert {:error, "doe"}
           |> then_ok(fn _v ->
             send(self(), :ignore)
             1
           end) == {:error, "doe"}

    refute_received :ignore
  end

  test "then_on/match" do
    assert :error
           |> then_on(:error, fn v ->
             send(self(), v)
             1
           end) == 1

    assert_received :error
  end

  test "then_on/bypass" do
    assert {:ok, "doe"}
           |> then_on(:error, fn _v ->
             send(self(), :ignore)
             1
           end) == {:ok, "doe"}

    refute_received :ignore
  end

  test "then_if/true" do
    assert :value
           |> then_if(true, fn v ->
             send(self(), v)
             v
           end) == :value

    assert_received :value
  end

  test "then_if/false" do
    assert :value
           |> then_if(false, fn v ->
             send(self(), v)
             v
           end) == :value

    refute_receive :value
  end
end
