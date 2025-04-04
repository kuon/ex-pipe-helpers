defmodule PipeHelpers do
  @moduledoc """
  Helpers for piping data. The provided helpers can be grouped into two categories:
  1. generate tuples that fit the return type of the containing function
  2. deal with previous function tuple output without "breaking the pipe"

  ## 1. Return tuples builders

  You can use only the first category to improve readability in your code.
  For instance, lets take a typical `Phoenix.LiveView` code:

      def mount(_params, _session, socket) do
        socket = assign(socket, my_bool_assign: true)
        {:ok, socket}
      end

  With `ok/1`, it can be rewritten as:

      def mount(_params, _session, socket) do
        socket
        |> assign( my_bool_assign: true)
        |> ok()
      end

  In addition to the typical `{:ok, value}` return tuple, the library provides
  the most common return types helpers `noreply/1` `reply/2`. Generic helpers
  are also provided to build whatever tuple you need with `pair/2` and `rpair/2`.

  ## 2. Tuple deconstructors

  In some situations, return type incompatibilities prevent you from using
  an uninterrupted pipe sequence. In this case, the following helpers may help:

  ### 2a Generic unpair

  The generic `unpair/1` allows you to ignore the first element of the pair
  and forward the second for further piping.

  ### 2b Only when "ok" execution

  The `then_ok/2` provides a promise-like solution to handle 'maybe ok'
  results. If the result is an ok-tuple, it executes the function on the second argument
  and passes the result forward (i.e. for further piping). If the result is not an
  ok-tuple (typically an `{:error, message}` tuple), it is forwarded directly.

  For example, let's take the following (very powerful translator) function:

      def translate(source) do
        case source do
          "ola" -> {:ok, "hello"}
          _ -> {:error, "can't translate, sorry"}
        end
      end

  And the quoting function that you want to pipe into:

      def quote(text) do
        text
      end

  The `translate/1` output doesn't fit the `quote/1` input, so the
  following pipe is not possible:

      my_source
      |> translate()
      |> quote()

  With the `then_ok/2` you can handle do:

      my_source
      |> translate()
      |> then_ok(&quote/1)

  This pipe will either return the properly quoted translation or the error tuple
  generated by the `translate/1`.

  > If you intend to successively pipe into more than a single functions after an
  > `{:ok, result}` returning function, you need to only have `{:ok, result}` functions
  > except the last one and always use the `then_ok/2` construct until the end. Doing so
  > you can safely do the error management at the end of the pipe using a `|> case do`
  > irrespective of the function that failed to provide an `{:ok, result}` output.


  The `then_on/3` provides similar behaviour with a more generic/powerful pattern
  matching on the previous function output.

  The functions above have their `tap` counterpart if the idea is to apply a
  conditional side effect without modifying the piped value.
  """

  @doc """
  Wrap into standard `{:ok, result}` tuple.

  ## Example

      iex> socket = "socket"
      ...> socket |> ok()
      {:ok, "socket"}

  """
  def ok(val) do
    {:ok, val}
  end

  @doc """
  Wrap into standard `{:error, result}` tuple.

  ## Example

      iex> :not_found |> err()
      {:error, :not_found}

  """
  def err(val) do
    {:error, val}
  end

  @doc """
  Wrap into `{:noreply, state}` tuple (genserver and phoenix socket format).

  ## Example

      iex> state = "gen server state"
      ...> state |> noreply()
      {:noreply, "gen server state"}

  """
  def noreply(val) do
    {:noreply, val}
  end

  @doc """
  Wrap into `{:reply, reply, state}` tuple (genserver and phoenix socket format).

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
  Wrap into `{:halt, state}` tuple (phoenix socket format).

  """
  def halt(state) do
    {:halt, state}
  end

  @doc """
  Wrap into `{:halt, reply, state}` tuple (phoenix socket format).

  """
  def halt(state, reply) do
    {:halt, reply, state}
  end

  @doc """
  Wrap into `{:cont, state}` tuple (phoenix socket format).

  """
  def cont(state) do
    {:cont, state}
  end

  @doc """
  Wrap into `{:reply, reply, state}` tuple (genserver and phoenix socket format).

  ## Example

      iex> state = "gen server state"
      ...> r = "reply"
      ...> r |> rreply(state)
      {:reply, "reply", "gen server state"}

  """
  def rreply(reply, state) do
    {:reply, reply, state}
  end

  @doc """
  Wrap into generic tuple pair.

  ## Example

      iex> 1 |> pair(2)
      {2, 1}

  """
  def pair(val, res) do
    {res, val}
  end

  @doc """
  Wrap into tuple rpair.

  ## Example

      iex> 1 |> rpair(2)
      {1, 2}

  """
  def rpair(val, res) do
    {val, res}
  end

  @doc """
  Unwrap from a tuple pair.

  ## Example

      iex> {:ok, 1} |> unpair()
      1

  """
  def unpair({_val, res}) do
    res
  end

  @doc """
  Unwrap a tuple, but raise if not `{:ok, value}`

  ## Example

      iex> {:ok, "hello"} |> unwrap!()
      "hello"

  """
  def unwrap!(val) do
    {:ok, val} = val
    val
  end

  @doc """
  Execute `fun` function only if `result` is an ok-tuple. Returns the input in any case.

  The `fun` argument is a function taking the right part of the ok-tuple
  as an optional argument.

  ## Example

      iex> {:ok, "somedata"} |> tap_ok(fn -> "only executed when {:ok, ...}" end)
      {:ok, "somedata"}

      iex> {:error, "failed"} |> tap_ok(fn -> "not executed when not {:ok, ...}" end)
      {:error, "failed"}
  """
  def tap_ok(result, fun) do
    then_ok(result, fun)
    result
  end

  @doc """
  Execute `fun` function only if the first arument matches the second one (`value = result` check).
  Returns the input in any case.

  ## Example

      iex> true |> tap_on(true, fn -> "only executed when matching 'true'" end)
      true

      iex> false |> tap_on(true, fn -> "not executed when not matchin 'true'" end)
      false
  """
  def tap_on(result, value, fun) do
    then_on(result, value, fun)
    result
  end

  @doc """
  If `result` is an ok tuple, execute `fun` with the right part of `result` tuple as single argument
  and return `fun` output.
  Otherwise, return `result` as-is.

  ## Example

      iex> {:ok, "somedata"} |> then_ok(fn -> "only returned when result argument is {:ok, ...}" end)
      "only returned when result argument is {:ok, ...}"

      iex> {:error, "failed"} |> then_ok(fn -> "only returned when result argument is {:ok, ...}" end)
      {:error, "failed"}

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

  def then_ok(:ok, fun) do
    fun.()
  end

  def then_ok(result, _fun), do: result

  @doc """
  Then only if value match. See `then_ok/2` and `tap_ok/3`
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

  @doc """
  Then only if condition is true.
  """
  def then_if(value, false, _), do: value

  def then_if(value, true, fun) do
    fun
    |> Function.info()
    |> Keyword.get(:arity)
    |> case do
      0 -> fun.()
      1 -> fun.(value)
      _ -> raise "then_if function arity can only be 0 or 1"
    end
  end

  def then_if(result, _cond, _fun), do: result
end
