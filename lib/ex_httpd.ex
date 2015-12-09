defmodule ExHttpd do
  use Application

  require ExHttpd.Request
  require ExHttpd.Response

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(Task.Supervisor, [[name: ExHttpd.TaskSupervisor]]),
      worker(Task, [ExHttpd, :accept, [8080]])
    ]

    opts = [strategy: :one_for_one, name: ExHttpd.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def accept(port) do
    {:ok, socket} = :gen_tcp.listen(port, [:binary, active: false, reuseaddr: true])
    IO.puts "Accepting connections on port #{port}"
    loop_acceptor(socket)
  end

  ################
  # private
  ################

  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    {:ok, pid} = Task.Supervisor.start_child(ExHttpd.TaskSupervisor, fn -> serve(client) end)

    case :gen_tcp.controlling_process(client, pid) do
      {:error, _} = error -> IO.puts "Error #{inspect(error)}"
      _ ->
    end
    loop_acceptor(socket)
  end

  defp serve(socket) do
    case get_message(socket, "") do
      :ok -> IO.puts "RX'd data"
      {:ok, response} ->
        IO.puts "Request info: #{inspect response}"
        :gen_tcp.send(socket, response[:data])
      {:error, :closed} -> IO.puts "Closed"
      {:error, _} = err -> err
    end
  end

  defp get_message(socket, message) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, buf} ->
        response = buf
        |> ExHttpd.Request.process
        |> ExHttpd.Response.reply
        {:ok, response}
      {:error, _} = error -> IO.puts "get_message error: #{inspect(error)}"
    end
  end
end
