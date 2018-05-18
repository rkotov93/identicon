defmodule Identicon do
  @moduledoc """
    Unique image generator
  """

  def main(input) do
    input
    |> input_hash
    |> pick_color
    |> build_grid
    |> filter_odd_value_squares
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end

  defp input_hash(input) do
    hex =
      :crypto.hash(:md5, input)
      |> :binary.bin_to_list

    %Identicon.Image{hex: hex}
  end

  defp pick_color(%Identicon.Image{hex: [r, g, b | _tail]} = image) do
    %Identicon.Image{image | color: {r, g, b}}
  end

  defp build_grid(%Identicon.Image{hex: hex_list} = image) do
    grid =
      hex_list
      |> Enum.chunk(3)
      |> Enum.map(&mirror_row/1)
      |> List.flatten
      |> Enum.with_index

    %Identicon.Image{image | grid: grid}
  end

  defp mirror_row([fst, snd | _tail] = row) do
    row ++ [snd, fst]
  end

  defp filter_odd_value_squares(%Identicon.Image{grid: grid} = image) do
    grid = Enum.filter grid, fn({value, _index}) ->
      rem(value, 2) == 0
    end

    %Identicon.Image{image | grid: grid}
  end

  defp build_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map = Enum.map grid, fn({_value, index}) ->
      x0 = rem(index, 5) * 50
      y0 = div(index, 5) * 50
      x1 = x0 + 50
      y1 = y0 + 50

      {{x0, y0}, {x1, y1}}
    end

    %Identicon.Image{image | pixel_map: pixel_map}
  end

  defp draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each pixel_map, fn({point1, point2}) ->
      :egd.filledRectangle(image, point1, point2, fill)
    end

    :egd.render(image)
  end

  defp save_image(image, input) do
    File.mkdir_p("./tmp")
    File.write("./tmp/#{input}.png", image)
  end
end
