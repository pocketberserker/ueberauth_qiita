# Überauth Qiita

[![Build Status](https://travis-ci.org/pocketberserker/ueberauth_qiita.svg?branch=master)](https://travis-ci.org/pocketberserker/ueberauth_qiita)
[![Hex Version][hex-img]][hex]

[hex-img]: https://img.shields.io/hexpm/v/ueberauth_qiita.svg
[hex]: https://hex.pm/packages/ueberauth_qiita

> Qiita OAuth2 strategy for Überauth.

Inspired by [Überauth for Facebook](https://github.com/ueberauth/ueberauth_facebook)

## Installation


1. Setup your application at [Qiita](https://qiita.com/settings/applications).

1. Add `ueberauth_qiita` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:ueberauth_qiita, "~> 0.1.0"}]
    end
    ```

1. Add the strategy to your applications:

    ```elixir
    def application do
      [applications: [:ueberauth_qiita]]
    end
    ```
1. Add Qiita to your Überauth configuration:

    ```elixir
    config :ueberauth, Ueberauth,
      providers: [
        qiita: {Ueberauth.Strategy.Qiita, []}
      ]
    ```

1.  Update your provider configuration:

    ```elixir
    config :ueberauth, Ueberauth.Strategy.Qiita.OAuth,
      client_id: System.get_env("QIITA_CLIENT_ID"),
      client_secret: System.get_env("QIITA_CLIENT_SECRET")
    ```

1.  Include the Überauth plug in your controller:

    ```elixir
    defmodule MyApp.AuthController do
      use MyApp.Web, :controller
      plug Ueberauth
      ...
    end
    ```

1.  Create the request and callback routes if you haven't already:

    ```elixir
    scope "/auth", MyApp do
      pipe_through :browser

      get "/:provider", AuthController, :request
      get "/:provider/callback", AuthController, :callback
    end
    ```

1. You controller needs to implement callbacks to deal with `Ueberauth.Auth` and `Ueberauth.Failure` responses.

## Calling

Depending on the configured url you can initial the request through:

    /auth/qiita

