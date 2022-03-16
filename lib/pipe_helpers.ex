defmodule PipeHelpers do
  @moduledoc """
  Helper for piping data
  """

  @doc """
  Wrap into ok tuple

  ## Example

  iex> socket = "socket"
  ...> socket |> ok()
  {:ok, "socket"}

  """
  def ok(val) do
    {:ok, val}
  end

  @doc """
  Wrap into noreply tuple (genserver and phoenix socket format)

  ## Example

  iex> state = "gen server state"
  ...> state |> noreply()
  {:noreply, "gen server state"}

  """
  def noreply(val) do
    {:noreply, val}
  end

  @doc """
  Wrap into reply tuple (genserver and phoenix socket format)

  ## Example

  iex> state = "gen server state"
  ...> r = "reply"
  ...> state |> reply(r)
  {:reply, "reply", "gen server state"}

  """
  def reply(state, reply) do
    {:reply, reply, state}
  end

  @doc """
  Wrap into tuple pair

  ## Example

  iex> 1 |> pair(2)
  {2, 1}

  """
  def pair(val, res) do
    {res, val}
  end

  @doc """
  Wrap into tuple rpair

  ## Example

  iex> 1 |> rpair(2)
  {1, 2}

  """
  def rpair(val, res) do
    {val, res}
  end

  @doc """
  Unwrap from a tuple pair

  ## Example

  iex> {:ok, 1} |> unpair()
  1

  """
  def unpair({_val, res}) do
    res
  end

  @doc """
  Tap only if ok tuple

  ## Example

  iex> {:ok, "somedata"} |> tap_ok(fn -> "only executed when {:ok, ...}" end)
  {:ok, "somedata"}

  iex> {:ok, "somedata"} |> tap_ok(fn _val ->
  ...>   _ = "only executed when {:ok, ...}"
  ...>   "val is available as optional argument"
  ...> end)
  {:ok, "somedata"}

  """
  def tap_ok(result, fun) do
    then_ok(result, fun)
    result
  end

  @doc """
  Tap only if value match

  ## Example

  iex> true |> tap_on(true, fn -> "only executed when true" end)
  true

  """
  def tap_on(result, value, fun) do
    then_on(result, value, fun)
    result
  end

  @doc """
  Then only if ok tuple

  ## Example

  iex> {:ok, "somedata"} |> then_ok(fn -> "only executed when {:ok, ...}" end)
  "only executed when {:ok, ...}"

  iex> {:ok, "somedata"} |> then_ok(fn val ->
  ...>   _ = "only executed when {:ok, ...}"
  ...>   _ = "val is available as optional argument"
  ...>   val
  ...> end)
  "somedata"

  """
  def then_ok({:ok, ok_val} = _result, fun) do
    fun
    |> Function.info()
    |> Keyword.get(:arity)
    |> case do
      0 -> fun.()
      1 -> fun.(ok_val)
      _ -> raise "then_ok function arity can only be 0 or 1"
    end
  end

  def then_ok(result, _fun), do: result

  @doc """
  Then only if value match
  """
  def then_on(value, value, fun) do
    fun
    |> Function.info()
    |> Keyword.get(:arity)
    |> case do
      0 -> fun.()
      1 -> fun.(value)
      _ -> raise "then_on function arity can only be 0 or 1"
    end
  end

  def then_on(result, _value, _fun), do: result
end
