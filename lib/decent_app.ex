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

  defp process(command, {bal, res}) do
    is_error =
      cond do
        length(res) < 1 ->
          if command == "DUP" || command == "POP" || command == "+" || command == "-" do
            true
          else
            false
          end

        length(res) < 2 ->
          if command == "+" || command == "-" do
            true
          else
            false
          end

        is_integer(command) ->
          if command < 0 || command > 10 do
            true
          else
            false
          end

        command != "NOTHING" && command != "DUP" && command != "POP" && command != "+" &&
          command != "-" && command != "COINS" && !is_integer(command) ->
          true

        true ->
          false
      end

    if is_error do
      {:halt, -1}
    else
      new_balance = %{bal | coins: bal.coins - 1}

      res =
        cond do
          command === "NOTHING" ->
            res

          true ->
            cond do
              command == "DUP" ->
                res ++ [List.last(res)]

              true ->
                if command == "POP" do
                  {_, res} = List.pop_at(res, length(res) - 1)
                  res
                else
                  cond do
                    command == "+" ->
                      [first, second | rest] = Enum.reverse(res)
                      Enum.reverse(rest) ++ [first + second]

                    command == "-" ->
                      [first, second | rest] = Enum.reverse(res)
                      Enum.reverse(rest) ++ [first - second]

                    is_integer(command) ->
                      res ++ [command]

                    command == "COINS" ->
                      res
                  end
                end
            end
        end

      new_balance =
        if command == "COINS" do
          %{new_balance | coins: new_balance.coins + 6}
        else
          new_balance
        end

      new_balance =
        if command == "+" do
          %{new_balance | coins: new_balance.coins - 1}
        else
          new_balance
        end

      {:cont, {new_balance, res}}
    end
  end
end
