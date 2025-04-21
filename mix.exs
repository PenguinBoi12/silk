defmodule Silk.MixProject do
  use Mix.Project

  @source_url "https://github.com/PenguinBoi12/silk"
  @version "0.1.0"

  def project do
    [
      app: :silk_html,
      version: @version,
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end

  defp description() do
    """
    Silk is a lightweight Elixir DSL for generating HTML in a clean, expressive, and composable 
    way - using just Elixir syntax.
    """
  end

  defp package() do
    [
      maintainers: ["Simon Roy"],
      licenses: ["GPL-3.0"],
      links: %{"GitHub" => @source_url}
    ]
  end

  defp docs() do
    [
      main: "readme",
      name: "Silk",
      source_ref: "v#{@version}",
      canonical: "http://hexdocs.pm/silk",
      source_url: @source_url,
      extras: ["README.md", "LICENSE"]
    ]
  end
end
