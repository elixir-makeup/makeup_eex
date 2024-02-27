defmodule MakeupEEx.MixProject do
  use Mix.Project

  @version "0.1.2"

  @url "https://github.com/elixir-makeup/makeup_eex"

  def project do
    [
      app: :makeup_eex,
      version: @version,
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      description: "(H)EEx lexer for makeup"
    ]
  end

  defp package do
    [
      name: :makeup_eex,
      licenses: ["BSD"],
      maintainers: ["Tiago Barroso <tmbb@campus.ul.pt>"],
      links: %{"GitHub" => @url}
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
      {:makeup_elixir, "~> 0.16 or ~> 1.0"},
      {:makeup_html, "~> 0.1.0 or ~> 1.0"},
      # Docs
      {:ex_doc, "~> 0.27", only: :dev, runtime: false}
    ]
  end
end
