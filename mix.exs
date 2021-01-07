defmodule ExDump.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_dump,
      version: "0.2.0",
      elixir: "~> 1.10",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      name: "ExDump",
      source_url: "https://github.com/kevinkoltz/ex_dump"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    []
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:phoenix_html, "~> 2.0"},
      {:decimal, "~> 2.0"},
      {:floki, "~> 0.0", only: :test}
    ]
  end

  defp description() do
    """
    Helper utility for dumping variables in EEx templates for easy
    inspection. Displays variables in nested tables that can be
    collapsed by clicking the headings.
    """
  end

  defp package() do
    [
      # These are the default files included in the package
      files: ~w(lib mix.exs README* LICENSE*),
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/kevinkoltz/ex_dump"}
    ]
  end
end
