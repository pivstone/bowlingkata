defmodule Bowlingkata.GameTest do
  use ExUnit.Case
  doctest Bowlingkata.Game

  # This means we can refer to BowlingKata.Game as just Game
  alias Bowlingkata.Game

  test "sums all the pins" do
    {:ok, game} = Game.start_link()
    Game.roll_many(game, 20, 1)
    assert Game.score(game) == 20
  end

  test "adds the next roll to a spare frame score" do
    {:ok, game} = Game.start_link()

    game
    |> Game.roll(6)
    |> Game.roll(4)
    |> Game.roll(3)
    |> Game.roll_many(17, 0)

    assert Game.score(game) == 16
  end

  test "a completed game test" do
    {:ok, game} = Game.start_link()

    game
    |> Game.roll(1)
    |> Game.roll(4)
    |> Game.roll(4)
    |> Game.roll(5)
    |> Game.roll(6)
    |> Game.roll(4)
    |> Game.roll(5)
    |> Game.roll(5)
    |> Game.roll(10)
    |> Game.roll(0)
    |> Game.roll(1)
    |> Game.roll(7)
    |> Game.roll(3)
    |> Game.roll(6)
    |> Game.roll(4)
    |> Game.roll(10)
    |> Game.roll(2)
    |> Game.roll(8)
    |> Game.roll(6)

    assert Game.score(game) == 133
  end
end
