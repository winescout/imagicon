defmodule Imagicon do
  @moduledoc """
  Generate a programatic identicon, like Github for users
  """

  @doc """
  Main access point for Imagicon generateor.  Pass a string, and will generate, and save an Imagicon

  ## Examples

      iex> Imagicon.main("hello")
      :world

  """
  def main(input) do
    image = input
      |> convert_to_hex
      |> set_color
      |> build_squares
      |> filter_colored_indexes
      |> build_pixel_map
  end

  defp convert_to_hex(input) do
    hex = :crypto.hash(:md5, input)
      |> :binary.bin_to_list

    %Imagicon.Image{hex: hex}
  end

  defp set_color( %Imagicon.Image{ hex: [r,g,b | _rest] } = image ) do
    %Imagicon.Image{ image | color: {r,g,b} }
  end

  defp build_squares( %Imagicon.Image{ hex: hex } = image ) do
    squares = hex
      |> Enum.chunk_every(3)
      |> Enum.filter( fn(row)-> Enum.count(row) == 3 end )
      |> Enum.map(&mirror_row/1)
      |> List.flatten

    %Imagicon.Image{ image | squares: squares } 
  end

  defp mirror_row([first, second | _rest] = row) do
    row ++ [second, first]
  end

  defp filter_colored_indexes(%Imagicon.Image{ squares: squares } = image) do
    odds = squares
      |> Enum.with_index
      |> Enum.filter(fn({ value, _index }) -> rem(value, 2) == 1 end)
      |> Enum.map(fn({ _value, index }) -> index end )

    %Imagicon.Image{ image | odd_indexes: odds }
  end

  defp build_pixel_map(%Imagicon.Image{ odd_indexes: odds } = image ) do
    map = odds
      |> Enum.map( fn( index ) ->
        horizontal = rem(index, 5) * 50
        vertical = div(index, 5) * 50

        top_left = {horizontal, vertical}
        bottom_right = {horizontal + 50, vertical + 50}

        {top_left, bottom_right}
      end)
  end

end

