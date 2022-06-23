defmodule VagabondHttp.Server do
  require Logger

  @messages %{
    200 => "Success",
    404 => "Not Found"
  }

  def serve(socket, client, router) do
    # Consume socket
    socket
    # Pass Socket to read/1(socket)
    |> read
    |> parse
    |> process(router)
    |> write(socket)
  end

  def read(socket) do
    # Read first line (method, /PATH/TO/REQ, HTTP/VERSION)
    {:ok, line} = :gen_tcp.recv(socket, 0)

    # Pass remainder of socket to read into the recursive header compilation function
    headers = compile_headers(socket)

    # Return first line of request with method, path, and socket, as well as compiled headers, as a tuple
    {line, headers}
  end

  defp compile_headers(socket, headers \\ []) do
    # Read next line of HTTP request from socket
    {:ok, line} = :gen_tcp.recv(socket, 0)

    # Regex conditional to ensure line being read is in header http-header-key: value format
    case Regex.run(~r/(\w+): (.*)/, line) do
      # If in format, save {key, value} into the headers value via recursive loop pass
      [_line, key, value] -> [{key, value}] ++ compile_headers(socket, headers)
      # If empty, request body starting
      _                   -> []
    end
  end

  def parse({line, headers}) do
    # Read the request method, path and version from first return line of HTTP request
    [method, path, version] = String.split(line)

    {path, query} = parse_uri(path)

    %{
      method: method,
      path: path,
      version: version,
      query: query,
      headers: headers
    }
  end

  def parse_uri(path) do
    # Split path string at ? to get query string
    case String.split(path) do
      # if no split at ?, no query string
      [path] -> {path, []}
      # if split at ?, there is a query string, return path and query as tuple
      [path, query] -> {path, query}
    end
  end

  def process(request, router) do
    router.route(request)
  end

  def write(response, socket) do
    IO.puts("in write")

    code = response[:code] || 500
    body = response[:body] || ""
    headers = format_headers(response[:headers])

    IO.inspect(code)
    IO.inspect(body)
    IO.inspect(headers)

    preamble = """
    HTTP/1.1 #{code} #{message(code)}
    Date: #{:httpd_util.rfc1123_date}
    Content-Type: #{response[:type] || "text/plain"}
    Content-Length: #{String.length(body)}
    IO.puts(headers)
    """


    raw = preamble <> headers <> "\n" <> body

    # ##IO.inspect(body)

    :gen_tcp.send(socket, raw)
  end

  defp format_headers(nil), do: ""
  defp format_headers(headers),
    do: Enum.map_join(headers, "\n", &format_header/1) <> "\n"

  defp format_header({key, value}),
    do: "#{key}: #{value}"

  # formatting status code message
  defp message(code), do: @messages[code] || "Unknown"

end
