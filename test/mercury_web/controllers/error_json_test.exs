defmodule MercuryWeb.ErrorJSONTest do
  use MercuryWeb.ConnCase, async: true

  test "renders 404" do
    assert MercuryWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert MercuryWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
