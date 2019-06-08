defmodule Identicon do
  def main(input) do
    input
    |> hash_input()
    |> pick_color()
    |> build_grid()
    |> filter_odd_squares()
  end

  defp filter_odd_squares(image) do
    %Identicon.Image{grid: grid} = image
    grid = Enum.filter(grid, fn({code, _index}) -> rem(code, 2) == 0 end)
    %Identicon.Image{image | grid: grid}
  end

  defp build_grid(image) do
    %Identicon.Image{hex: hex} = image
    grid =
      hex
      |> Enum.chunk_every(3, 3, :discard)
      |> Enum.map(&mirror_row/1)
      |> List.flatten()
      |> Enum.with_index()

    %Identicon.Image{image | grid: grid}
  end

  defp mirror_row(row) do
    [first, second | _tail] = row
    row ++ [second, first]
  end

  defp pick_color(image) do
    %Identicon.Image{hex: [r, g, b | _tail]} = image
    %Identicon.Image{image | color: {r, g, b}}
  end

  defp hash_input(input) do
    hex = :crypto.hash(:md5, input) |> :binary.bin_to_list
    %Identicon.Image{hex: hex}
  end
end
