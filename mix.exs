defmodule PipeHelpers.MixProject do
  use Mix.Project

  @source_url "https://github.com/kuon/ex-pipe-helpers"
  @version "1.2.0"

  def project do
    [
      name: "PipeHelpers",
      app: :pipe_helpers,
      version: @version,
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      description: description(),
      package: package(),
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description() do
    "A small set of helpers to help structure pipelines"
  end

  defp deps do
    [
      # EX Docs generation
      {:ex_doc, "~> 0.24", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      main: "readme",
      source_url: @source_url,
      output: "docs/",
      extras: [
        "README.md"
      ]
    ]
  end

  defp package() do
    [
      licenses: ["Apache-2.0", "MIT"],
      links: %{"Git" => @source_url}
    ]
  end
end
