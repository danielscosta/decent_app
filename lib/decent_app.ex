defmodule DecentApp do
  alias DecentApp.Balance

  def call(%Balance{} = balance, commands) do
    commands
    |> Enum.reduce_while({balance, []}, &process/2)
    |> case do
      {balance, result} when balance.coins > 0 ->
        {balance, result}

      _ ->
        -1
    end
  end

  defp process(command, {_bal, []}) when command in ["DUP", "POP", "+", "-"], do: {:halt, -1}

  defp process(command, {_bal, [_elem]}) when command in ["+", "-"], do: {:halt, -1}

  defp process(command, {_bal, res}) when command in ["*"] and length(res) < 3, do: {:halt, -1}

  defp process(command, {_bal, _res}) when is_integer(command) and (command < 0 or command > 10),
    do: {:halt, -1}

  defp process(command, {_bal, _res})
       when not is_integer(command) and
              command not in ["NOTHING", "DUP", "POP", "+", "-", "COINS", "*"],
       do: {:halt, -1}

  defp process(command, {bal, res}) when is_integer(command),
    do: {:cont, {%{bal | coins: bal.coins - 1}, res ++ [command]}}

  defp process("NOTHING", {bal, res}), do: {:cont, {%{bal | coins: bal.coins - 1}, res}}

  defp process("DUP", {bal, res}),
    do: {:cont, {%{bal | coins: bal.coins - 1}, res ++ [List.last(res)]}}

  defp process("POP", {bal, res}),
    do: {:cont, {%{bal | coins: bal.coins - 1}, res |> List.pop_at(length(res) - 1) |> elem(1)}}

  defp process("+", {bal, res}) do
    [first, second | rest] = Enum.reverse(res)
    res = Enum.reverse(rest) ++ [first + second]

    {:cont, {%{bal | coins: bal.coins - 2}, res}}
  end

  defp process("-", {bal, res}) do
    [first, second | rest] = Enum.reverse(res)
    res = Enum.reverse(rest) ++ [first - second]

    {:cont, {%{bal | coins: bal.coins - 1}, res}}
  end

  defp process("*", {bal, res}) do
    [first, second, third | rest] = Enum.reverse(res)
    res = Enum.reverse(rest) ++ [first * second * third]

    {:cont, {%{bal | coins: bal.coins - 3}, res}}
  end

  defp process("COINS", {bal, res}), do: {:cont, {%{bal | coins: bal.coins + 5}, res}}
end
