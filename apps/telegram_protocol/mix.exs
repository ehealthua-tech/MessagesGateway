defmodule TelegramProtocol.MixProject do
  use Mix.Project

  def project do
    [
      app: :telegram_protocol,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/dev.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test],
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {TelegramProtocol.Application, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:db_agent, in_umbrella: true},
      {:httpoison, "~> 1.4"},
      {:jason, "~> 1.1"},
      {:plug_cowboy, "~> 1.0"},
      {:tdlib, "~> 0.0.2"},
      {:redix, ">= 0.0.0"},
      {:excoveralls, "~> 0.10", only: :test},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false}
    ]
  end
end
