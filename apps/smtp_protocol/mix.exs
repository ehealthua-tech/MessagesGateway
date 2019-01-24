defmodule SmtpProtocol.MixProject do
  use Mix.Project

  def project do
    [
      app: :smtp_protocol,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/dev.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {SmtpProtocol.Application, []},
      extra_applications: [:logger, :bamboo, :bamboo_smtp]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
      # {:sibling_app_in_umbrella, in_umbrella: true},
      {:bamboo_smtp, "~> 1.6"},
      {:amqp, "~> 1.0"}
    ]
  end
end
