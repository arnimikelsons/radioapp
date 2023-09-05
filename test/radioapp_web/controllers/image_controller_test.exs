defmodule RadioappWeb.ImageControllerTest do
  use RadioappWeb.ConnCase
  alias Radioapp.Repo
  alias Radioapp.Factory
  alias Radioapp.Station
  alias Radioapp.Station.Image

  @tenant "sample"
  @prefix Triplex.to_prefix(@tenant)

  @valid_attrs %Plug.Upload{
    content_type: "image/jpg",
    filename: "cat.jpg",
    path: "test/support/files/cat-three.jpg"
  }
  @update_attrs %Plug.Upload{
    content_type: "image/jpg",
    filename: "another-cat.jpg",
    path: "test/support/files/cat-eight.jpg"
  }
  @invalid_attrs %Plug.Upload{
    content_type: nil,
    filename: nil,
    path: nil
  }

  def image_fixture(_attrs \\ %{}) do
    program = Factory.insert(:program, [], prefix: @prefix)

    assert {:ok, %Image{} = image} =
             Station.create_image_from_plug_upload(
               program,
               @valid_attrs, 
               @tenant
             )

    image
    |> Repo.preload(program: [])
  end
    #describe "index" do
    #  test "lists all images", %{conn: conn} do
    #    conn = get(conn, ~p"/images")
    #    assert html_response(conn, 200) =~ "CFRC Programs"
    #  end
    #end

    describe "manage programs" do
      setup %{conn: conn} do
        user = Factory.insert(:user, roles: %{@tenant => "user"})

        conn = log_in_user(conn, user)
        %{conn: conn, user: user}
      end

      test "renders form", %{conn: conn} do
        conn = get(conn, ~p"/programs/new")
        assert html_response(conn, 200) =~ "New Program"
      end


    test "redirects to show when data is valid", %{conn: conn} do
      program = Factory.insert(:program, [], prefix: @prefix)
      conn = post(conn, ~p"/programs/#{program.id}/images", image: @valid_attrs)

      assert %{id: _id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/programs/#{program.id}"

      conn = get(conn, ~p"/programs/#{program.id}")
      assert html_response(conn, 200) =~ program.name
    end

    test "renders errors when data is invalid for New Program", %{conn: conn} do
      program = Factory.insert(:program, [], prefix: @prefix)
      conn = post(conn, ~p"/programs/#{program.id}/images", image: @invalid_attrs)
      assert redirected_to(conn) =~ ~p"/programs/#{program.id}"
    end

    test "redirects when data is valid", %{conn: conn} do
      image = image_fixture()

      conn = put(conn, ~p"/programs/#{image.program.id}/images/#{image.id}", image: @update_attrs)
      assert redirected_to(conn) == ~p"/programs/#{image.program_id}"

      conn = get(conn, ~p"/programs/#{image.program_id}")
      refute html_response(conn, 200) =~ "Upload Image"
    end

    test "renders errors when data is invalid for Edit", %{conn: conn} do
      image = image_fixture()

      conn = put(conn, ~p"/programs/#{image.program_id}/images/#{image.id}", program: @invalid_attrs)
      assert redirected_to(conn) == ~p"/programs/#{image.program_id}"

    end

    test "deletes chosen program", %{conn: conn} do
      image = image_fixture()
      conn = delete(conn, ~p"/programs/#{image.program_id}/images/#{image.id}")
      assert redirected_to(conn) == ~p"/programs/#{image.program_id}"

    end
  end
end
