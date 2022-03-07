defmodule MakeupEEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :makeup_eex,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Makeup.Lexers.EExLexer.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:makeup, "~> 1.0"},
      {:nimble_parsec, "~> 1.2"},
      # Sub-languages
      {:makeup_elixir, "~> 0.16"},
      {:makeup_html, "~> 0.1.0"},
      # Benchmarking utilities
      {:benchee, "~> 1.0", only: :dev},
      {:benchee_markdown, "~> 0.2", only: :dev}
    ]
  end
end
