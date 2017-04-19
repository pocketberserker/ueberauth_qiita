defmodule UeberauthQiita.Mixfile do
  use Mix.Project

  @url "https://github.com/pocketberserker/ueberauth_qiita"

  def project do
    [app: :ueberauth_qiita,
     version: "0.1.0",
     package: package,
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     source_url: @url,
     homepage_url: @url,
     description: description,
     deps: deps(),
     docs: docs]
  end

  def application do
    [applications: [:logger, :oauth2, :ueberauth]]
  end

  defp docs do
    [extras: ["README.md"]]
  end

  defp description do
    "An Uberauth strategy for Qiita authentication."
  end

  defp deps do
    [{:ueberauth, "~> 0.4"},
     {:oauth2, "~> 0.8.0"},
     {:ex_doc, "~> 0.2", only: :dev},
     {:earmark, ">= 0.0.0", only: :dev}]
  end

  defp package do
    [files: ["lib", "mix.exs", "README.md", "LICENSE"],
      maintainers: ["pocketberserker"],
      licenses: ["MIT"],
      links: %{"GitHub": @url}]
  end
end
