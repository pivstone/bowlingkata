defmodule Bowlingkata.Game do
  @moduledoc false
  use GenServer
  require Logger
  alias Bowlingkata.Frame

  # bouns rate
  defstruct rate: 0,
            extra: 0,
            frames: [%Frame{first: 0, second: 0, completed: true}]

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, [])
  end

  def init(_) do
    {:ok, %__MODULE__{}}
  end

  def roll(_pid, pin) when pin > 10 or pin < 0 do
    {:error, :should_be_under_10}
  end

  def roll(pid, pin) when pin <= 10 do
    GenServer.call(pid, {:roll, pin})
    pid
  end

  def roll_many(pid, times, pin) do
    GenServer.call(pid, {:roll_many, times, pin})
    pid
  end

  def score(pid) do
    GenServer.call(pid, :score)
  end

  def handle_call(:score, _, %__MODULE__{frames: [current | _]} = state) do
    {:reply, current.score, state}
  end

  def handle_call({:roll, pin}, _, %__MODULE__{} = state) do
    {:reply, nil, hit(pin, state)}
  end

  def handle_call({:roll_many, times, pin}, _, %__MODULE__{} = state) do
    {:reply, nil, hit_many(times, pin, state)}
  end

  defp hit(pin, _) when pin > 10 or pin < 0, do: raise("invailed pin")

  defp hit(_, %__MODULE__{rate: rate, frames: [%Frame{completed: completed} | _] = frames})
       when length(frames) == 11 and rate == 0 and completed == true,
       do: raise("game_alreay_over")

  # when the last frame is a strike or a spare
  # play has a extra turn
  defp hit(
         pin,
         %__MODULE__{
           rate: rate,
           frames: [%Frame{completed: completed} = current | other] = frames
         } = state
       )
       when length(frames) == 11 and rate > 0 and completed == true do
    new_current = %Frame{current | score: current.score + pin}
    %__MODULE__{state | frames: [new_current | other], extra: pin + state.extra, rate: rate - 1}
  end

  # Step
  # 1st update frame: insert a new frame into frames
  # or update the uncompleted current frame
  #
  # 2nd cacluate the score
  # 3rd counter the bouns rate
  defp hit(pin, %__MODULE__{} = state) do
    state
    |> update_frame(pin)
    |> calc_score(pin)
    |> check_bouns
  end

  defp hit_many(times, _pin, state) when times <= 0 do
    state
  end

  defp hit_many(times, pin, state) do
    state = hit(pin, state)
    hit_many(times - 1, pin, state)
  end

  # when last frame is a strike or a spare
  # this turn's point should be double
  # and update the current frame and the last frame's score
  defp calc_score(%__MODULE__{rate: rate, frames: [current | [last | frames]]} = state, pin)
       when rate > 0 do
    new_last_frames = %Frame{last | score: last.score + pin}

    new_current = %Frame{
      current
      | score: current.score + pin + pin
    }

    new_frames = [new_current | [new_last_frames | frames]]
    %__MODULE__{state | rate: rate - 1, frames: new_frames}
  end

  defp calc_score(%__MODULE__{rate: rate, frames: [current | frames]} = state, pin)
       when rate == 0 do
    new_current = %Frame{current | score: current.score + pin}
    %__MODULE__{state | frames: [new_current | frames]}
  end

  # when this frame is completed
  # Another new frame should be created
  # when the pin is 10 (This frame is a strike)
  # The new frame will be created as a completed frame with two scores
  # (the first turn's score is 10, the second turn's score is Zero)
  defp update_frame(
         %__MODULE__{frames: [%Frame{completed: completed} = current | _] = frames} = state,
         pin
       )
       when completed == true do
    new_frame = Frame.new(pin, current.score)
    %__MODULE__{state | frames: [new_frame | frames]}
  end

  defp update_frame(
         %__MODULE__{frames: [current | frames]} = state,
         pin
       ) do
    if current.first + pin > 10 do
      raise "invalid pin"
    end

    new_frame = %Frame{current | second: pin, completed: true}

    %__MODULE__{
      state
      | frames: [new_frame | frames]
    }
  end

  defp check_bouns(
         %__MODULE__{
           rate: rate,
           frames: [current | _]
         } = state
       ) do
    %__MODULE__{
      state
      | rate: Frame.bouns(current) + rate
    }
  end
end
