defmodule ExDump do
  @moduledoc """
  Helper utility for dumping variables in EEx templates for easy inspection.
  """
  use Phoenix.HTML

  @doc """
  Dumps a term to html in a easy to read format.
  """
  @spec dump(any(), keyword()) :: {:safe, String.t()}
  def dump(term, opts \\ []) do
    theme = Keyword.get(opts, :theme, :default)

    {:safe, dump_html} = to_html(term)

    [
      ~s(<div id="dump-wrapper" class="-ex-dump">),
      dump_html,
      ~s(</div>),
      css(theme)
    ]
    |> Enum.join("\n")
    |> raw()
  end

  defp to_html(nil), do: dump_simple_term(:empty, "nil")
  defp to_html(value) when is_binary(value), do: dump_simple_term(:binary, value)
  defp to_html(value) when is_boolean(value), do: dump_simple_term(:boolean, value)
  defp to_html(value) when is_integer(value), do: dump_simple_term(:integer, value)
  defp to_html(value) when is_tuple(value), do: dump_simple_term(:tuple, inspect(value))
  defp to_html(%Decimal{} = value), do: dump_simple_term(:decimal, value)
  defp to_html(%Date{} = value), do: dump_simple_term("Date", value)
  defp to_html(%DateTime{} = value), do: dump_simple_term("Datetime", value)
  defp to_html(value) when is_atom(value), do: dump_simple_term(:atom, inspect(value))
  defp to_html(%NaiveDateTime{} = value), do: dump_simple_term("Naive Datetime", value)

  defp to_html(%{__struct__: struct} = value) do
    struct_name = inspect(struct)

    value
    |> Map.from_struct()
    |> dump_complex_term("map", ~s[Struct: #{struct_name}])
  end

  defp to_html(value) when is_map(value), do: dump_complex_term(value, "map", "Map")

  defp to_html(values) when is_list(values) do
    values
    |> Enum.with_index()
    |> Enum.map(fn {value, index} -> {index + 1, value} end)
    |> dump_complex_term("list", "List")
  end

  # catch all
  defp to_html(values), do: dump_simple_term("uknown", inspect(values))

  defp dump_simple_term(type, value)
       when type in [:atom, :binary, :boolean, :decimal, :integer, :tuple] do
    """
    <table>
      <tbody>
        <tr>
          <td class="dump-data-type">#{type}</td>
          <td class="dump-data-value">#{value}</td>
        </tr>
      </tbody>
    </table>
    """
    |> raw()
  end

  defp dump_simple_term(type, value) do
    """
    <table>
      <tbody>
        <tr>
          <td class="dump-data-type">#{type}</td>
        </tr>
        <tr>
          <td class="dump-data-value">#{value}</td>
        </tr>
      </tbody>
    </table>
    """
    |> raw()
  end

  defp dump_complex_term(values, name, title) do
    fingerprint = random_string()

    rows =
      values
      |> Enum.map(fn {key, value} ->
        {:safe, value_html} = to_html(value)

        """
        <tr class="#{fingerprint}">
          <td class="dump-header dump-#{name}-header">#{inspect(key)}</td>
          <td class="dump-#{name}-value">
            #{value_html}
          </td>
        </tr>
        """
      end)
      |> Enum.join("\n")

    toggle_javascript =
      "var elements = document.getElementsByClassName('#{fingerprint}'); " <>
        "for(var i = 0; i < elements.length; i++) { " <>
        "elements[i].style.display = elements[i].style.display == 'none' ? '' : 'none'; }"

    """
    <table>
      <tbody>
        <tr>
          <td class="dump-header dump-#{name}-header" onclick="#{toggle_javascript}" colspan="3" style="cursor:pointer;">
            <span>#{title}</span>
          </td>
        </tr>
        #{rows}
      </tbody>
    </table>
    """
    |> raw()
  end

  defp css(:default) do
    """
    <style type="text/css">
      #dump-wrapper table {
        font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
        font-size: 11px;
        empty-cells: show;
        color: #000;
        border-collapse: collapse;
        margin: 0;
      }
      #dump-wrapper td {
        border: 1px solid #000;
        vertical-align: top;
        padding: 2px;
        empty-cells: show;
      }
      #dump-wrapper td span {
        font-weight: bold;
      }
      #dump-wrapper td.dump-map-value {
        color: #333399;
        border-color: #333399;
        background-color: #ccf;
      }
      #dump-wrapper td.dump-map-header {
        color: #333399;
        border-color: #333399;
        background-color: #99f;
      }
      #dump-wrapper td.dump-data-value {
        color: #990000;
        border-color: #990000;
        background-color: #fc9;
      }
      #dump-wrapper td.dump-data-type {
        color: #990000;
        border-color: #990000;
        background-color: #f60;
      }
      #dump-wrapper td.dump-list-value {
        color: #336600;
        border-color: #336600;
        background-color: #cf3;
      }
      #dump-wrapper td.dump-list-header {
        color: #336600;
        border-color: #336600;
        background-color: #9c3;
      }
    </style>
    """
  end

  defp random_string(length \\ 6) do
    length |> :crypto.strong_rand_bytes() |> Base.url_encode64() |> binary_part(0, length)
  end
end
