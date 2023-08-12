defmodule RadioappWeb.ImageController do
  use RadioappWeb, :controller

  alias Radioapp.Station
  alias Radioapp.Station.Image

  def index(conn, _params) do
    images = Station.list_images()
    render(conn, "index.html", images: images)
  end

  def show(conn, %{"id" => id}) do
    image = Station.get_image!(id)
    image_data = Station.download_from_s3(image.remote_filename)

    send_download(conn, {:binary, image_data}, 
    filename: image.filename,
    content_type: image.content_type)
  end

  def new(conn, %{"program_id" => program_id}) do
    program = Station.get_program!(program_id)

    changeset = Station.change_image(%Image{})

    render(conn, "new.html",
      program: program,
      changeset: changeset
    )
  end

  def create(conn, %{
        "program_id" => program_id,
        "image" => %Plug.Upload{} = image
      }) do

    program = Station.get_program!(program_id)

    case Station.create_image_from_plug_upload(
           program,
           image
         ) do
      {:ok, _image} ->
        conn
        |> put_flash(:info, "File uploaded successfully.")
        |> redirect(to: ~p"/programs/#{program}")

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Issue uploading image.")
        |> redirect(to: ~p"/programs/#{program}")
    end
  end

  def create(conn, %{"program_id" => program_id}) do
    conn
    |> put_flash(:error, "Please select an image to upload.")
    |> redirect(to: ~p"/programs/#{program_id}")
  end

  def update(conn, %{
    "program_id" => program_id,
    "id" => image_id,
    "image" => %{"image" => %Plug.Upload{} = image_upload}
  }) do

    image = Station.get_image!(image_id)

    case Station.update_image_from_plug(
          image,
          image_upload
        ) do
      {:ok, _image} ->
        conn
        |> put_flash(:info, "Image uploaded successfully.")
        |> redirect(to: ~p"/programs/#{program_id}")

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Issue uploading image.")
        |> redirect(to: ~p"/programs/#{program_id}")
    end
  end

  def update(conn, %{"program_id" => program_id}) do
    conn
    |> put_flash(:error, "Issue uploading image.")
    |> redirect(to: ~p"/programs/#{program_id}")
  end

  def delete(conn, %{"id" => id}) do
    image = Station.get_image!(id)
    program = Station.get_program!(image.program_id)
    {:ok, _image} = Station.delete_image(image)

    conn
    |> put_flash(:info, "Image deleted successfully.")
    |> redirect(to: ~p"/programs/#{program.id}")
  end
end
