defmodule NewsAggregator.MixProject do
  use Mix.Project

  def project do
    [
      app: :news_aggregator,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {NewsAggregator.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.6"},
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.0"},
      {:plug_attack, git: "https://github.com/nbap/plug_attack.git", branch: "updates"},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false}
    ]
  end
end
