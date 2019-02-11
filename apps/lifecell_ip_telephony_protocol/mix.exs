defmodule LifecellIpTelephonyProtocol.MixProject do
  use Mix.Project

  def project do
    [
      app: :lifecell_ip_telephony_protocol,
      version: "0.1.0",
      elixir: "~> 1.7",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test],
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {LifecellIpTelephonyProtocol.Application, []}
#      applications: [:ex_ami]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.4"},
      {:redix, ">= 0.0.0"},
      {:excoveralls, "~> 0.10", only: :test},
#      {:speak_ex, "~> 0.3"},
    ]
  end
end
