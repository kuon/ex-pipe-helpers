defmodule FlowTest do
  use ExUnit.Case
  doctest PipeHelpers.Flow, import: true
  alias PipeHelpers.Flow

  test "start ok" do
    assert Flow.start(:a, fn ->
      {:ok, "a val"}
    end) == {:ok, %{a: "a val"}}
  end

  test "start error" do
    assert Flow.start(:a, fn ->
      {:error, "error"}
    end) == {:error, %{}, :a, "error"}
  end

  test "simple ok" do
    assert Flow.start(:a, fn ->
      {:ok, "a val"}
    end)
    |> Flow.then_ok(:b, fn %{a: a} ->
      assert a == "a val"
      {:ok, "b val"}
    end)
    == {:ok, %{a: "a val", b: "b val"}}
  end

  test "simple new ok" do
    assert Flow.new()
    |> Flow.then_ok(:a, fn %{} ->
      {:ok, "a val"}
    end)
    |> Flow.then_ok(:b, fn %{a: a} ->
      assert a == "a val"
      {:ok, "b val"}
    end)
    == {:ok, %{a: "a val", b: "b val"}}
  end

  test "simple error" do
    assert Flow.start(:a, fn ->
      {:ok, "a val"}
    end)
    |> Flow.then_ok(:b, fn ->
      {:error, :not_found}
    end)
    == {:error, %{a: "a val"}, :b, :not_found}
  end

  test "ok with map" do
    assert Flow.start(:a, fn ->
      {:ok, "a val"}
    end)
    |> Flow.then_ok(:b, fn %{a: a} ->
      assert a == "a val"
      {:ok, "b val"}
    end)
    |> Flow.map_ok(fn %{b: b} ->
      b <> b
    end)
    == "b valb val"
  end
end

