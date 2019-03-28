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
  def track(event, user_id, properties) do
    body = %{
      event: event,
      userId: user_id,
      properties: properties,
      context: context()
    }

    case Poison.encode(body) do
      {:ok, http_body} ->
        post("#{@endpoint}/track", http_body, headers())

      {:error, _} = error ->
        error
    end
  end

  def identify(user_id, traits) do
    body = %{userId: user_id, traits: traits, context: context()}

    case Poison.encode(body) do
      {:ok, http_body} ->
        post("#{@endpoint}/identify", http_body, headers())

      {:error, _} = error ->
        error
    end
  end

  def context,
    do: %{library: %{name: "elixir-segment-api", version: @app_version}}

  def process_response_status_code(200), do: Logger.debug("#{__MODULE__} successfully called")

  def process_response_status_code(status_code),
    do: Logger.info("#{__MODULE__} not successfully called, returned #{status_code}")

  defp headers, do: [Authorization: auth_header(), "Content-Type": "application/json"]

  defp auth_header,
    do: "Basic #{Base.encode64(Application.get_env(:segment_api, :api_key, "") <> ":")}"
end
