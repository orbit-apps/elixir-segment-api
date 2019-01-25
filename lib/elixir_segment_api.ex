defmodule ElixirSegmentAPI do
  @moduledoc """
  Segment API
  """
  use HTTPoison.Base
  require Logger

  @endpoint "https://api.segment.io/v1"
  # As per docs https://segment.com/docs/sources/server/http/
  @auth_header "Basic #{
                 Base.encode64(Application.get_env(:elixir_segment_api, :api_key, "") <> ":")
               }"

  @doc """
    -> ElixirSegmentAPI.track(bad, bad, bad)
      # {:error, "invalid poison"}
  """
  def track(event, userId, properties) do
    case Poison.encode(%{event: event, userId: userId, properties: properties}) do
      {:ok, http_body} ->
        post("#{@endpoint}/track", http_body, headers())

      {:error, _} = error ->
        error
    end
  end

  def event(app_slug, type), do: "#{app_slug} #{get_event_text(type)}"

  def process_response_status_code(200), do: Logger.debug("#{__MODULE__} successfully called")

  def process_response_status_code(status_code),
    do: Logger.info("#{__MODULE__} not successfully called, returned #{status_code}")

  defp headers, do: [Authorization: @auth_header, "Content-Type": "application/json"]

  defp get_event_text(:customer_redact), do: "Customer Data Removal Requested"
  defp get_event_text(:customer_data_request), do: "Customer Data Requested"
  defp get_event_text(:shop_redact), do: "Data Removal Requested"
end
