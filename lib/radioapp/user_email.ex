defmodule Radioapp.UserEmail do
  import Swoosh.Email

  def welcome() do
    new()
    |> to({"Arni", "arni@northernvillage.com"})
    |> from({"RadioApp", "radioapp@northernvillage.net"})
    |> subject("Hello, Avengers!")
    |> html_body("<h1>Hello Arni</h1>")
    |> text_body("Hello Arni\n")
  end
end
