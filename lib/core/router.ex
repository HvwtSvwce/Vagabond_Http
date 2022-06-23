defmodule VagabondHttp.Router do


  def route(req) do

    case req.method do
      "GET" ->
        _gets(req.path, req.query)
      "POST" ->
        "post logic"
      "PUT" ->
        "put logic"
    end

  end

  def _gets(path, query \\ []) do
    IO.inspect("here we go in gets")
    if query == [] do
      case path do
        "/" ->
          IO.inspect("in /")
          try do
            return_doc = EEx.eval_file("lib/htdocs/index.eex")
            %{code: 200, type: "text/html", body: return_doc}
          rescue
            x ->
              %{code: 404, type: "text/plain", body: "404 - File not found: #{x.path}"}
          end


      end
    else
      case path do
        "/get_something" -> "send query into controller"
      end
    end
  end

end
