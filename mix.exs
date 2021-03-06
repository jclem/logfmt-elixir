defmodule Logfmt.MixProject do
  use Mix.Project

  @version "3.3.2"
  @source_url "https://github.com/jclem/logfmt-elixir"

  def project do
    [
      app: :logfmt,
      version: @version,
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Hex
      description: description(),
      package: package(),
      source_url: @source_url,
      docs: docs()
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
      {:ex_doc, "~> 0.24.2", only: :dev, runtime: false}
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
      links: %{"GitHub" => @source_url},
      maintainers: ["Jonathan Clem <jonathan@jclem.net>"],
      files: ~w(mix.exs lib README.md LICENSE.md)
    ]
  end

  defp docs do
    [
      source_ref: "v#{@version}",
      main: "readme",
      extras: ["README.md": [title: "Readme"], "LICENSE.md": [title: "License"]]
    ]
  end
end
