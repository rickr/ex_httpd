defmodule ExHttpd.Response do

  def reply(request) do
    request
      |> new_response
      |> set_status_line
      |> set_content_type
      |> set_content
      |> format_request
  end



  ###############
  # private
  ###############
  defp new_response(data) do
    %{
      status_line: %{
        version: nil,
        status_code: nil,
        reason_phrase: nil
      },
      headers: [
        {"Content-Type", ""},
      ],
      content: "",
      data: ""
    }
  end

  defp set_status_line(response) do
    status_line = response[:status_line]
      |> Map.put(:version, "HTTP/1.1")
      |> Map.put(:status_code, "200")
      |> Map.put(:reason_phrase, "OK")
    response = Map.put(response, :status_line, status_line)
    response
  end

  defp set_content_type(response) do
    headers = List.keyreplace(response[:headers], "Content-Type", 0, {"Content-Type", "text/html"})
    response = Map.put(response, :headers, headers)
    response
  end

  defp set_content(response) do
    response = Map.put(response, :content, "hello world")
    response
  end

  defp format_request(response) do
    data = format_status_line(response)
            |> format_headers(response)
            |> set_content_length(response)
            |> format_content(response)
    response = Map.put(response, :data, data)
    response
  end

  defp format_status_line(response) do
    response[:status_line][:version] <> " "
    <> response[:status_line][:status_code] <> " "
    <> response[:status_line][:reason_phrase] <> "\r\n"
  end

  defp format_headers(formatted_response, response) do
    headers = response[:headers]
    formatted_response <> format_header(headers, "")
  end

  defp format_header([head|tail], formatted_headers) when is_tuple(head) do
    {key, value} = head
    format_header(tail, formatted_headers <> key <> ": " <> value <> "\r\n")
  end

  defp format_header([head|tail], formatted_headers) do
    format_header(tail, formatted_headers)
  end

  defp format_header([], formatted_headers) do
    formatted_headers
  end

  defp format_content(formatted_response, response) do
    formatted_response <> response[:content]
  end

  defp set_content_length(formatted_response, response) do
    content_length = byte_size(response[:data]) + byte_size(response[:content])
    formatted_response <> "Content-Length: #{content_length}\r\n\r\n"
  end
end
