defmodule SegmentAPI do
  @moduledoc """
  Segment API
  """
  use HTTPoison.Base
  require Logger

  @endpoint "https://api.segment.io/v1"
  # As per docs https://segment.com/docs/sources/server/http/
  @app_version Keyword.get(Mix.Project.config(), :version)

  @doc """
    -> SegmentAPI.track(bad, bad, bad)
      # {:error, "invalid poison"}
  """
  def track(event, user_id, properties, options \\ %{}) do
    body = %{
      event: event,
      userId: user_id,
      properties: properties,
      context: context(),
      integrations: Map.get(options, :integrations)
    }

    body
    |> remove_nil_values()
    |> Poison.encode()
    |> post_or_return_error("track")
  end

  def identify(user_id, traits, options \\ %{}) do
    body = %{
      userId: user_id,
      traits: traits,
      context: context(),
      integrations: Map.get(options, :integrations)
    }

    body
    |> remove_nil_values()
    |> Poison.encode()
    |> post_or_return_error("identify")
  end

  def context,
    do: %{library: %{name: "elixir-segment-api", version: @app_version}}

  defp remove_nil_values(map) do
    map
    |> Enum.reject(fn {_, v} -> is_nil(v) end)
    |> Enum.into(%{})
  end

  defp post_or_return_error({:ok, http_body}, path), do: post_to_segment(path, http_body)

  defp post_or_return_error({:error, _} = error, _), do: error

  defp post_to_segment(path, http_body), do: post("#{@endpoint}/#{path}", http_body, headers())

  def process_response_status_code(200), do: Logger.debug("#{__MODULE__} successfully called")

  def process_response_status_code(status_code),
    do: Logger.info("#{__MODULE__} not successfully called, returned #{status_code}")

  defp headers, do: [Authorization: auth_header(), "Content-Type": "application/json"]

  defp auth_header,
    do: "Basic #{Base.encode64(Application.get_env(:segment_api, :api_key, "") <> ":")}"
end
