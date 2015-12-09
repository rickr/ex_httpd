defmodule ExHttpd.Request do

  def process(data) do
    data
      |> new_request
      |> parse_request_line
      |> parse_headers
  end

  ###############
  # private
  ###############
  defp new_request(data) do
    request_lines = String.split(data, "\r\n")
    %{
      request_line:
        %{
          method: nil,
          uri: nil,
          version: nil,
        },
      headers: [],
      original_data: request_lines,
      remaining_data: request_lines
    }
  end

  defp parse_request_line(request) do
    [method, uri, version] = String.split(hd(request[:original_data]))
    remaining_data = tl(request[:original_data])

    request = Map.put(request, :method, method)
    request = Map.put(request, :uri, uri)
    request = Map.put(request, :version, version)
    request = Map.put(request, :remaining_data, remaining_data)
    request
  end

  defp parse_headers(request) do
    headers = extract_headers([], request[:remaining_data])
    request = Map.put(request, :headers, headers)
    request
  end

  defp extract_headers(headers, [head|tail]) do
    if String.contains? head, ":" do
      [k, v] = String.split(head, ":", parts: 2)
      headers = headers ++ [%{key: String.strip(k), value: String.strip(v)}]
    end
    extract_headers(headers, tail)
  end

  defp extract_headers(headers, []) do
    headers
  end
end
