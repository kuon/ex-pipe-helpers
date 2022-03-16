# PipeHelpers

Pipe helpers are a set of simple helpers for elixir to help structure code with
pipes.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `pipe_helpers` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:pipe_helpers, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/pipe_helpers>.


## Documentation


The library is documented in the
[main module documentation](https://hexdocs.pm/pipe_helpers/PipeHelpers.html).

Small example:

```elixir
  import PipeHelpers

  # Example in a live view
  @impl true
  def mount(_params, _session, socket) do
    socket
    |> assign(loading: true)
    |> ok()
  end

```


