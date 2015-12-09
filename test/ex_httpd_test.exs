defmodule ExHttpdTest do
  use ExUnit.Case
  doctest ExHttpd

  def mock_request do
    "GET /a-path HTTP/1.1\r\nFake-Header: Fake Value\r\nFake-Header: value:with-colon\r\n"
  end


  #
  #
  # Request
  test "request data is populated" do
    request = ExHttpd.Request.process(mock_request)
    assert String.split(mock_request, "\r\n") == request[:original_data]
  end

  test "request method is extracted" do
    request = ExHttpd.Request.process(mock_request)
    assert "GET" == request[:method]
  end

  test "URI is extracted" do
    request = ExHttpd.Request.process(mock_request)
    assert "/a-path" == request[:uri]
  end

  test "version is extracted" do
    request = ExHttpd.Request.process(mock_request)
    assert "HTTP/1.1" == request[:version]
  end

  test "headers are parsed" do
    request = ExHttpd.Request.process(mock_request)
    first_header = hd(request[:headers])
    assert first_header[:key] == "Fake-Header"
    assert first_header[:value] == "Fake Value"
  end

  #
  #
  # Response
  test "status line is set" do
    response = ExHttpd.Response.reply(mock_request)
    assert response[:status_line][:version] == "HTTP/1.1"
    assert response[:status_line][:status_code] == "200"
    assert response[:status_line][:reason_phrase] == "OK"
  end

  test "content-type is set" do
    response = ExHttpd.Response.reply(mock_request)
    assert response[:headers]["Content-Type"] == "text/html"
  end

  test "content is set" do
    response = ExHttpd.Response.reply(mock_request)
    assert response[:content]== "hello world"
  end
end
