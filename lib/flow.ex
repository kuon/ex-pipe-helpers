defmodule PipeHelpers.Flow do
  def new() do
    {:ok, %{}}
  end

  def start(name, fun) do
    start(name, %{}, fun)
  end

  def start(name, init, fun) do
    then_ok({:ok, init}, name, fun)
  end

  def then_ok({:ok, state}, name, fun) do
    if Map.has_key?(state, name) do
      raise ArgumentError, message: "name #{name} is already used in flow"
    end

    fun
    |> Function.info()
    |> Keyword.get(:arity)
    |> case do
      0 -> fun.()
      1 -> fun.(state)
      _ -> raise "then_ok function arity can only be 0 or 1"
    end
    |> case do
      {:ok, val} ->
        if is_nil(name) do
          state
        else
          Map.put(state, name, val)
        end
        |> PipeHelpers.ok()

      {:error, e} ->
        {:error, state, name, e}

      e ->
        {:error, state, name, e}
    end
  end

  def then_ok(result, _, _fun), do: result

  def tap_ok(result, fun) do
    then_ok(result, nil, fun)
    result
  end

  def map_ok({:ok, state}, fun) do
    fun
    |> Function.info()
    |> Keyword.get(:arity)
    |> case do
      0 -> fun.()
      1 -> fun.(state)
      _ -> raise "then_ok function arity can only be 0 or 1"
    end
  end

  def map_ok(result, _fun), do: result
end
