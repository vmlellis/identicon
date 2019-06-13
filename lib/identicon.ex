defmodule Identicon do
  def main(input) do
    input
    |> hash_input()
    |> pick_color()
    |> build_grid()
    |> filter_odd_squares()
    |> build_pixel_map()
    |> draw_image()
  end

  defp draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)
    Enum.each pixel_map, fn({start, stop}) ->
      :egd.filledRectangle(image, start, stop, fill)
    end

    :egd.render(image)
  end

  defp build_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map = Enum.map grid, fn({_code, index}) ->
      horizontal = rem(index, 5) * 50
      vertical = div(index, 5) * 50

      top_left = {horizontal, vertical}
      bottom_right = {horizontal + 50, vertical + 50}

      {top_left, bottom_right}
    end

    %Identicon.Image{image | pixel_map: pixel_map}
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
