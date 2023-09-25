defmodule Radioapp.Accounts.OrganizationTenant do
  require Logger

  alias Radioapp.Accounts
  alias Radioapp.Accounts.Org
  alias Radioapp.Admin
  alias Radioapp.Repo

  def create(%{"tenant_name" => tenant} = attrs) do
    result =
      Triplex.create_schema(tenant, Repo, fn tenant, repo ->
        {:ok, _} = Triplex.migrate(tenant, repo)

        seed_defaults(attrs, tenant)
      end)

    case result do
      {:ok, _tenant_name} ->
        case Repo.get_by(Org, tenant_name: tenant) do
          %Org{} = org -> {:ok, org}
          nil -> {:error, :org_not_found}
        end

      {:error, "ERROR 42P06 (duplicate_schema)" <> _} ->
        {:error, :duplicate_schema}

      {:error, reason} ->
        {:error, reason}
    end
  end
  def seed_defaults(attrs, tenant) do

    Repo.transaction(fn ->
      with {:ok, org} <- Accounts.create_org(attrs),
          {:ok, _} <- create_admin(tenant), 
          {:ok, _} <- create_category(tenant, %{code: "11", name: "News"}),
           {:ok, _} <- create_category(tenant, %{code: "12", name: "Spoken Word / PSAs"}),
           {:ok, _} <- create_category(tenant, %{code: "21", name: "Pop/Rock/RPM/Beatbox/Loud"}),
           {:ok, _} <- create_category(tenant, %{code: "22", name: "Country"}),
           {:ok, _} <- create_category(tenant, %{code: "23", name: "Acoustic performances"}),
           {:ok, _} <- create_category(tenant, %{code: "24", name: "Easy Listening"}),
           {:ok, _} <- create_category(tenant, %{code: "31", name: "Concert/Classical"}),
           {:ok, _} <- create_category(tenant, %{code: "32", name: "Folk"}),
           {:ok, _} <- create_category(tenant, %{code: "33", name: "World (including Reggae)"}),
           {:ok, _} <- create_category(tenant, %{code: "34", name: "Jazz/Blues"}),
           {:ok, _} <- create_category(tenant, %{code: "35", name: "Non-classic Religious (incl. Gospel)"}),
           {:ok, _} <- create_category(tenant, %{code: "36", name: "Experimental"}),
           {:ok, _} <- create_category(tenant, %{code: "41", name: "Musical themes, bridges and stingers"}),
           {:ok, _} <- create_category(tenant, %{code: "42", name: "Technical Tests"}),
           {:ok, _} <- create_category(tenant, %{code: "43", name: "Recorded station IDs"}),
           {:ok, _} <- create_category(tenant, %{code: "44", name: "Musical identification of announcers"}),
           {:ok, _} <- create_category(tenant, %{code: "45", name: "Station/Show promos"}),
           {:ok, _} <- create_category(tenant, %{code: "51", name: "Ads"}),
           {:ok, _} <- create_category(tenant, %{code: "52", name: "Sponsor identification"}),
           {:ok, _} <- create_category(tenant, %{code: "53", name: "Promotion with sponsor mention"}),

           {:ok, _} <- create_link(tenant, %{icon: "fa-regular fa-window-maximize", type: "Website" }),
           {:ok, _} <- create_link(tenant, %{icon: "fa-brands fa-twitter ", type: "Twitter" }),
           {:ok, _} <- create_link(tenant, %{icon: "fa-brands fa-facebook ", type: "Facebook" }),
           {:ok, _} <- create_link(tenant, %{icon: "fa-brands fa-spotify", type: "Spotify" }),
           {:ok, _} <- create_link(tenant, %{icon: "fa-brands fa-instagram", type: "Instagram" }),
           {:ok, _} <- create_link(tenant, %{icon: "fa-brands fa-tiktok", type: "TikTok" }) do


          #{:ok, _} <- create_textfield(tenant),
          #{:ok, _} <- create_settings(tenant) do
          #{:ok, _} <- create_worker_user(tenant) do
         org
        else
          {:error, reason} ->
            Repo.rollback(reason)
        end
    end)
  end

  defp create_admin(tenant) do
    Radioapp.Accounts.seeds_user(
      %{
        email: "arni+#{tenant}@northernvillage.com",
        password: "super-secret",
        hashed_password: Bcrypt.hash_pwd_salt("super-secret"),
        roles: %{tenant => "admin"},
        full_name: "NV Info",
        short_name: "Admin",
        confirmed_at: DateTime.utc_now()
      }
    )
  end

  defp create_category(tenant, category) do
    Admin.create_category(category, tenant)
  end

  defp create_link(tenant, link) do
    Admin.create_link(link, tenant)
  end


  # defp create_textfield(tenant) do
  #   Giftingapp.Admin.create_textfield(
  #     %{home_intro: """
  #     # Welcome to GiftingApp

  #     There are many families who are unable to afford the luxury of gifts or necessities like groceries during the holiday season. In fact, this time of year can add extra stress for a family who is already struggling to make ends meet. The GiftingApp Program matches donors with families in need in order to make Christmas shine a little brighter.

  #     Families are referred by social and community service agencies who have identified they are in need. The families include single moms and dads, children being raised by grandparents, low-income two-parent families, and independent-living youth.

  #     *While GiftingApp is a Christmas holiday program, it is open to people of all backgrounds and traditions.*

  #     If you are a social-community Worker, please [Register here](/worker-registration/new).

  #     If you are a Donor looking to adopt a family please [sign up here](/donors/new).
  #     """,
  #       contact: """
  #       # Contact

  #       GiftingApp Phone: <phone number> (October - December)
  #       Children's Foundation Phone: <phone number> (year-round)

  #       Email: <email>
  #       """,
  #       donor_area_intro: "# Thank you for signing up to be an GiftingApp Donor",
  #       donor_attachment_email: "Thank you so much for helping a family or independent youth through the GiftingApp Program. Our team of volunteer Elves have matched you as closely as possible with your budget and any other information you’ve provided, and you will find your family match attached.",
  #       donor_intro: "# Welcome to GiftingApp",
  #       donor_intro_email: "WHAT'S NEXT? Our volunteers will be processing your donor registration and will be in touch with your family or independent youth match by email within 2-5 business days. If you don’t see an email from us, please check your Spam folder just in case (or Promotions folder in Gmail).",
  #       donor_pdf_letter: "Thank you so much for helping a family or independent youth through the GiftingApp Program. Our team of volunteer Elves have matched you as closely as possible with your budget and any other information you’ve provided, and you will find your family match(es) in this attachment.",
  #       donor_terms_and_conditions: "Yes, I agree to receive emails from the your GiftingApp for marketing purposes, which will include information regarding the GiftingApp, and other charitable opportunities, initiatives and events. I understand that I can withdraw my consent at any time. For more details see our Privacy Policy.",
  #       donor_thankyou: """
  #       # Thank you for signing up to bring hope and joy home for the holidays!

  #       Our volunteers will be processing your donor registration and will be in touch with your family or independent youth match by email within 2-5 business days. If you don’t see an email from us, please check your Spam folder just in case (or Promotions folder in Gmail).

  #       Any questions, please email us at <email> or call <phone number>
  #       """,
  #       terms_and_conditions: "# Donor terms and conditions",
  #       worker_intro: "# Register to GiftingApp",
  #       worker_thankyou: """
  #       # Thank you for registering

  #       We’ve received your registration to refer families to the GiftingApp Program. You should hear from us within a business day to let you know that your Worker account has been activated so that you can begin submitting Family Referrals.

  #       Any questions, please email us at <email>

  #       GiftingApp Team
  #       """,
  #       worker_intro_email: "We've received your registration to refer families to the Adopt-A-Family Program. You should hear from us within a business day to let you know that your Worker account has been activated so that you can begin submitting Family Referrals. Any questions, please email us at <email> "
  #     },
  #     tenant
  #   )
  # end

  # defp create_settings(tenant) do
  #   Admin.create_settings(
  #     %{
  #       program_name: "GiftingApp Program",
  #       disable_logins: false,
  #       from_email: "giftingapp@northernvillage.net",
  #       from_email_name: "GiftingApp",
  #       org_name: "GiftingApp",
  #       logo_path: "/images/GiftingApp-logo.png"
  #     },
  #     tenant
  #   )
  # end
end
