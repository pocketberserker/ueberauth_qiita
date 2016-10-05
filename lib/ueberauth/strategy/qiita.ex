defmodule Ueberauth.Strategy.Qiita do
  @moduledoc """
  Qiita Strategy for Überauth.
  """

  use Ueberauth.Strategy, default_scope: "read_qiita",
                          uid_field: :id,
                          allowed_request_params: [
                            :auth_type,
                            :scope,
                            :state
                          ]

  alias Ueberauth.Auth.Info
  alias Ueberauth.Auth.Credentials
  alias Ueberauth.Auth.Extra

  @doc """
  Handles initial request for Qiita authentication.
  """
  def handle_request!(conn) do
    allowed_params = conn
      |> option(:allowed_request_params)
      |> Enum.map(&to_string/1)

    authorize_url = conn.params
      |> maybe_replace_param(conn, "auth_type", :auth_type)
      |> maybe_replace_param(conn, "scope", :default_scope)
      |> maybe_replace_param(conn, "state", :state)
      |> Enum.filter(fn {k,_v} -> Enum.member?(allowed_params, k) end)
      |> Enum.map(fn {k,v} -> {String.to_existing_atom(k), v} end)
      |> Keyword.put(:redirect_uri, callback_url(conn))
      |> Ueberauth.Strategy.Qiita.OAuth.authorize_url!

    redirect!(conn, authorize_url)
  end

  @doc """
  Handles the callback from Qiita.
  """
  def handle_callback!(%Plug.Conn{params: %{"code" => code}} = conn) do
    opts = [redirect_uri: callback_url(conn)]
    token = Ueberauth.Strategy.Qiita.OAuth.get_token!([code: code], opts)

    if token.access_token == nil do
      err = token.other_params["error"]
      desc = token.other_params["error_description"]
      set_errors!(conn, [error(err, desc)])
    else
      fetch_user(conn, token)
    end
  end

  @doc false
  def handle_callback!(conn) do
    set_errors!(conn, [error("missing_code", "No code received")])
  end

  @doc false
  def handle_cleanup!(conn) do
    conn
    |> put_private(:qiita_user, nil)
    |> put_private(:qiita_token, nil)
  end

  @doc """
  Fetches the uid field from the response.
  """
  def uid(conn) do
    uid_field =
      conn
      |> option(:uid_field)
      |> to_string

    conn.private.qiita_user[uid_field]
  end

  @doc """
  Includes the credentials from the qiita response.
  """
  def credentials(conn) do
    token = conn.private.qiita_token
    scopes = token.other_params["scope"] || ""
    scopes = String.split(scopes, ",")

    %Credentials{
      expires: !!token.expires_at,
      expires_at: token.expires_at,
      scopes: scopes,
      token: token.access_token
    }
  end

  @doc """
  Fetches the fields to populate the info section of the
  `Ueberauth.Auth` struct.
  """
  def info(conn) do
    user = conn.private.qiita_user

    %Info{
      description: user["description"],
      image: user["profile_image_url"],
      name: user["name"],
      nickname: user["id"],
      urls: %{
        qiita: "https://twitter.com/#{user["id"]}",
        website: user["website_url"]
      }
    }
  end

  @doc """
  Stores the raw information (including the token) obtained from
  the qiita callback.
  """
  def extra(conn) do
    %Extra{
      raw_info: %{
        token: conn.private.qiita_token,
        user: conn.private.qiita_user
      }
    }
  end

  defp fetch_user(conn, token) do
    conn = put_private(conn, :qiita_token, token)
    path = "/api/v2/authenticated_user"
    case OAuth2.AccessToken.get(token, path) do
      {:ok, %OAuth2.Response{status_code: 401, body: _body}} ->
        set_errors!(conn, [error("token", "unauthorized")])
      {:ok, %OAuth2.Response{status_code: status_code, body: user}}
        when status_code in 200..399 ->
        put_private(conn, :qiita_user, user)
      {:error, %OAuth2.Error{reason: reason}} ->
        set_errors!(conn, [error("OAuth2", reason)])
    end
  end

  defp option(conn, key) do
    default = Dict.get(default_options, key)

    conn
    |> options
    |> Dict.get(key, default)
  end
  defp option(nil, conn, key), do: option(conn, key)
  defp option(value, _conn, _key), do: value

  defp maybe_replace_param(params, conn, name, config_key) do
    if params[name] do
      params
    else
      Map.put(
        params,
        name,
        option(params[name], conn, config_key)
      )
    end
  end
end
