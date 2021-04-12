defmodule Logfmt.MixProject do
  use Mix.Project

  def project do
    [
      app: :logfmt,
      version: "3.3.1",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Hex
      description: description(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Type `mix help deps` for more examples and options
  defp deps do
    [
      {:ex_doc, "~> 0.22.0", only: :dev, runtime: false}
    ]
  end

  defp description do
    """
    Logfmt is a module for encoding and decoding logfmt-style log lines.
    """
  end

  defp package do
    [
      contributors: ["Jonathan Clem <jotclem@gmail.com>"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/jclem/logfmt-elixir"},
      maintainers: ["Jonathan Clem <jonathan@jclem.net>"],
      files: ~w(mix.exs lib README.md LICENSE.md)
    ]
  end
end
