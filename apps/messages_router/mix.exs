defmodule MessagesRouter.MixProject do
  use Mix.Project

  def project do
    [
      app: :messages_router,
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
      mod: {MessagesRouter.Application, []},
      extra_applications: [:logger, :amqp]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:amqp, "~> 1.0"},
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
      # {:sibling_app_in_umbrella, in_umbrella: true},
      {:amqp, "~> 1.0"},
      {:dialyxir, "~> 1.0.0-rc.4", only: [:dev], runtime: false},
      {:excoveralls, "~> 0.10", only: :test},
      {:jason, "~> 1.1"},
      {:httpoison, "~> 1.4"},
      {:redix, ">= 0.0.0"}
    ]
  end
end
