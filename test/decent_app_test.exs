defmodule DecentAppTest do
  use ExUnit.Case
  doctest DecentApp

  alias DecentApp.Balance

  describe "Awesome tests" do
    test "success" do
      balance = %Balance{coins: 10}

      {new_balance, result} =
        DecentApp.call(balance, [3, "DUP", "COINS", 5, "+", "NOTHING", "POP", 7, "-", 9])

      assert new_balance.coins == 5
      assert length(result) > 1
    end

    test "failed" do
      assert DecentApp.call(%Balance{coins: 10}, [
               3,
               "DUP",
               "FALSE",
               5,
               "+",
               "NOTHING",
               "POP",
               7,
               "-",
               9
             ]) == -1

      assert DecentApp.call(%Balance{coins: 1}, [3, 5, 6]) == -1
      assert DecentApp.call(%Balance{coins: 10}, ["+"]) == -1
      assert DecentApp.call(%Balance{coins: 10}, ["-"]) == -1
      assert DecentApp.call(%Balance{coins: 10}, ["DUP"]) == -1
      assert DecentApp.call(%Balance{coins: 10}, ["POP"]) == -1
    end
  end

  describe "Multiple Feature" do
    test "success" do
      balance = %Balance{coins: 10}

      {new_balance, result} = DecentApp.call(balance, [1, 2, 3, 5, "*"])

      assert new_balance.coins == 3
      assert [1, 30] == result

      {new_balance, result} = DecentApp.call(balance, [1, 1, 2, 2, "*"])

      assert new_balance.coins == 3
      assert [1, 4] == result
    end

    test "failed" do
      balance = %Balance{coins: 10}

      assert DecentApp.call(balance, [1, 2, "*"]) == -1

      balance = %Balance{coins: 2}

      assert DecentApp.call(balance, [1, 1, 2, 2, "*"]) == -1
    end
  end
end
