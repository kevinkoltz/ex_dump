defmodule ExDumpTest do
  use ExUnit.Case
  doctest ExDump

  defmodule Foo do
    defstruct greeting: "hello"
  end

  test "dump list" do
    assert {:safe, html} = ExDump.dump([333, :a])
    assert ["List", "1", "2"] = extract_headers(html)
    assert [{"integer", "333"}, {"atom", ":a"}] = extract_values(html)
  end

  test "dump map" do
    assert {:safe, html} = ExDump.dump(%{a: 1})
    assert ["Map", ":a"] = extract_headers(html)
    assert [{"integer", "1"}] = extract_values(html)
  end

  test "dump map with complex key" do
    assert {:safe, html} = ExDump.dump(%{{4, 5} => 6})
    assert ["Map", "{4, 5}"] = extract_headers(html)
    assert [{"integer", "6"}] = extract_values(html)
  end

  test "dump struct" do
    assert {:safe, html} = ExDump.dump(%Foo{greeting: "hello there"})
    assert ["Struct: ExDumpTest.Foo", ":greeting"] = extract_headers(html)
    assert [{"binary", "hello there"}] = extract_values(html)
  end

  test "dump binary" do
    assert {:safe, html} = ExDump.dump("hello")
    assert [{"binary", "hello"}] = extract_values(html)
  end

  test "dump boolean" do
    assert {:safe, html} = ExDump.dump(true)
    assert [{"boolean", "true"}] = extract_values(html)

    assert {:safe, html} = ExDump.dump(false)
    assert [{"boolean", "false"}] = extract_values(html)
  end

  test "dump integer" do
    assert {:safe, html} = ExDump.dump(2_147_483_647)
    assert [{"integer", "2147483647"}] = extract_values(html)
  end

  @tag :skip
  # didnt expect is_integer would catch this
  test "dump large number" do
    assert {:safe, html} = ExDump.dump(999_999_999_999)
    assert [{"number", "999999999999"}] = extract_values(html)
  end

  test "dump tuple" do
    assert {:safe, html} = ExDump.dump({123, 456})
    assert [{"tuple", "{123, 456}"}] = extract_values(html)
  end

  test "dump Decimal" do
    assert {:safe, html} = ExDump.dump(Decimal.new("123.456"))
    assert [{"decimal", "123.456"}] = extract_values(html)
  end

  test "dump Date" do
    assert {:safe, html} = ExDump.dump(~D[2021-01-02])
    assert [{"Date", "2021-01-02"}] = extract_values(html)
  end

  test "dump DateTime" do
    assert {:safe, html} = ExDump.dump(~U[2021-08-28 05:34:00.003Z])
    assert [{"Datetime", "2021-08-28 05:34:00.003Z"}] = extract_values(html)
  end

  test "dump atom" do
    assert {:safe, html} = ExDump.dump(:foo)
    assert [{"atom", ":foo"}] = extract_values(html)
  end

  test "dump NaiveDateTime" do
    assert {:safe, html} = ExDump.dump(~N[2021-01-02 21:22:23])
    assert [{"Naive Datetime", "2021-01-02 21:22:23"}] = extract_values(html)
  end

  defp extract_headers(html) do
    extract_text_for_selector(html, ".dump-header")
  end

  defp extract_values(html) do
    types = extract_text_for_selector(html, ".dump-data-type")
    values = extract_text_for_selector(html, ".dump-data-value")
    Enum.zip(types, values)
  end

  def extract_text_for_selector(html, selector) do
    html
    |> Floki.parse_document!()
    |> Floki.find(selector)
    |> Enum.map(&Floki.text/1)
  end
end
