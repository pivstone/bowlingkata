defmodule Bowlingkata.Frame do
  @moduledoc false

  defstruct first: -1,
            second: -1,
            score: 0,
            completed: false

  @doc """

  iex> frame = #{__MODULE__}.new(7)
  iex> frame.score
  0
  iex> frame.first
  7
  iex> frame.second
  -1

  iex> frame = #{__MODULE__}.new(10)
  iex> frame.score
  0
  iex> frame.first
  10
  iex> frame.second
  0

  """
  def new(pin, score \\ 0)

  def new(pin, score) when pin == 10,
    do: %__MODULE__{first: pin, second: 0, score: score, completed: true}

  def new(pin, score), do: %__MODULE__{first: pin, score: score}

  @doc """
  checking frame bouns rates
  If this frame is a strike, the bouns is 2
  If this frame is a spare , the bouns is 1
  otherwise the bouns is ZERO

  iex> frame = %#{__MODULE__}{}
  iex> #{__MODULE__}.bouns(frame)
  0

  iex> frame = %#{__MODULE__}{first: 10, second: 0}
  iex> #{__MODULE__}.bouns(frame)
  2

  iex> frame = %#{__MODULE__}{first: 4, second: 6}
  iex> #{__MODULE__}.bouns(frame)
  1
  """
  def bouns(%__MODULE__{first: first, second: second}) when first == 10 and second == 0, do: 2
  def bouns(%__MODULE__{first: first, second: second}) when first + second == 10, do: 1
  def bouns(%__MODULE__{}), do: 0
end
