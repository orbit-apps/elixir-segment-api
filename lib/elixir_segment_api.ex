defmodule SegmentAPI do
  @moduledoc """
  Segment API
  """

  @base_url "https://api.segment.io/v1"
  # As per docs https://segment.com/docs/sources/server/http/
  @app_version Keyword.get(Mix.Project.config(), :version)

  def track(event, user_id, properties, options \\ %{}) do
    body = %{
      event: event,
      userId: user_id,
      properties: properties,
      context: context(),
      integrations: Map.get(options, :integrations)
    }

    new_request()
    |> Req.run(url: "/track", json: remove_nil_values(body))
  end

  def identify(user_id, traits, options \\ %{}) do
    body = %{
      userId: user_id,
      traits: traits,
      context: context(),
      integrations: Map.get(options, :integrations)
    }

    new_request()
    |> Req.run(url: "/identify", json: remove_nil_values(body))
  end

  def context,
    do: %{library: %{name: "elixir-segment-api", version: @app_version}}

  defp remove_nil_values(%{} = map),
    do: map |> Enum.reject(fn {_, v} -> is_nil(v) end) |> Enum.into(%{})

  defp new_request do
    Req.Request.new(method: :post, base_url: @base_url)
    |> append_application_headers()
    |> append_authorization_header()
  end

  defp append_application_headers(%Req.Request{} = req) do
    req
    |> Req.Request.put_header("accept", "application/json")
    |> Req.Request.put_header("content-type", "application/json")
  end

  defp append_authorization_header(%Req.Request{} = req),
    do: Req.Request.put_header(req, "Authorization", "Basic #{Base.encode64(api_key() <> ":")}")

  defp api_key, do: Application.get_env(:segment_api, :api_key, "")
end
