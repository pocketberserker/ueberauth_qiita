defmodule Ueberauth.Strategy.Qiita.OAuth do
  @moduledoc """
  OAuth2 for Qiita.
  Add `client_id` and `client_secret` to your configuration:
  config :ueberauth, Ueberauth.Strategy.Qiita.OAuth,
    client_id: System.get_env("QIITA_APP_ID"),
    client_secret: System.get_env("QIITA_APP_SECRET")
  """
  use OAuth2.Strategy

  @defaults [
    strategy: __MODULE__,
    site: "https://qiita.com/api",
    authorize_url: "https://qiita.com/api/v2/oauth/authorize",
    token_url: "https://qiita.com/api/v2/access_tokens",
  ]

  @doc """
  Construct a client for requests to Qiita.
  This will be setup automatically for you in `Ueberauth.Strategy.Qiita`.
  These options are only useful for usage outside the normal callback phase
  of Ueberauth.
  """
  def client(opts \\ []) do
    config = Application.get_env(:ueberauth, Ueberauth.Strategy.Qiita.OAuth)

    opts =
      @defaults
      |> Keyword.merge(config)
      |> Keyword.merge(opts)

    OAuth2.Client.new(opts)
  end

  @doc """
  Provides the authorize url for the request phase of Ueberauth.
  No need to call this usually.
  """
  def authorize_url!(params \\ [], opts \\ []) do
    opts
    |> client
    |> OAuth2.Client.authorize_url!(params)
  end

  def get_token!(params \\ [], opts \\ []) do
    resp = opts
      |> client
      |> OAuth2.Client.get_token!(params)
    %{resp | access_token: resp.other_params["token"]}
  end

  # Strategy Callbacks

  def authorize_url(client, params) do
    OAuth2.Strategy.AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    client
    |> put_header("Content-Type", "application/json")
    |> put_header("Accept", "application/json")
    |> OAuth2.Strategy.AuthCode.get_token(params, headers)
  end
end
