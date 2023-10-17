![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/kuon/ex-pipe-helpers/elixir.yml?branch=main)
![Hex.pm](https://img.shields.io/hexpm/v/pipe_helpers)
![License Hex.pm](https://img.shields.io/hexpm/l/pipe_helpers)


# PipeHelpers

Pipe helpers are a set of simple helpers for elixir to help structure code with
pipes.

## Installation

The package can be installed
by adding `pipe_helpers` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:pipe_helpers, "~> 1.0.1"}
  ]
end
```


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


