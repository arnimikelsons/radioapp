defmodule Radioapp.Factory do
  use ExMachina.Ecto, repo: Radioapp.Repo

  def unique_user_email, do: "user#{System.unique_integer()}@nvlocal.net"
  def valid_user_password, do: "hello world!"

def user_factory do
  %Radioapp.Accounts.User{
    full_name: "Some Full Name",
    short_name: "Some Short Name",
    confirmed_at: ~N[2000-01-01 23:00:07],
    email: unique_user_email(),
    password: valid_user_password(),
    hashed_password: Bcrypt.hash_pwd_salt(valid_user_password())
  }
end

  def program_factory do
    %Radioapp.Station.Program{
      name: Faker.Company.name() |> String.replace("'", ""),
      description: Faker.Lorem.Shakespeare.as_you_like_it() |> String.replace("'", ""),
      timeslots: [],
      hide: false,
      images: nil,
      link1: nil,
      link2: nil,
      link3: nil,
      link1_url: Faker.Internet.url(),
      link2_url: Faker.Internet.url(),
      link3_url: Faker.Internet.url()
    }
  end

  def timeslot_factory() do

    %Radioapp.Station.Timeslot{
      day: 1,
      starttime: ~T[18:00:00],
      runtime: 30,
      starttimereadable: "6:00 pm"
    }
  end

  def timeslot_now_factory() do
    now = DateTime.to_naive(Timex.now("America/Toronto"))
    time_now = DateTime.to_time(Timex.now("America/Toronto"))
    weekday = Timex.weekday(now)

    %Radioapp.Station.Timeslot{
      day: weekday,
      starttime: time_now,
      runtime: 30
    }
  end

  def log_factory do
    date_now = DateTime.to_date(Timex.now("America/Toronto"))
    time_now = DateTime.to_time(Timex.now("America/Toronto"))

    %Radioapp.Station.Log{
      host_name: Faker.Superhero.name(),
      date: date_now,
      start_time: time_now,
      end_time: Time.add(time_now, 30, :minute),
      category: Faker.Airports.En.name(),
      language: sequence(:language, ["English", "French", "Swahili"]),
      notes: Faker.Lorem.Shakespeare.hamlet() |> String.replace("'", "")
    }
  end
  def segment_factory do
    time_now = DateTime.to_time(Timex.now("America/Toronto"))

    %Radioapp.Station.Segment{
      artist: Faker.Person.En.name(),
      can_con: sequence(:can_con, [true, false]),
      catalogue_number: Integer.to_string(Faker.random_between(10000, 99999)),
      end_time: Time.add(time_now, 3, :minute),
      hit: sequence(:hit, [true, false]),
      instrumental: sequence(:instrumental, [true, false]),
      new_music: sequence(:new_music, [true, false]),
      start_time: time_now,
      song_title: Faker.Pizza.style()
    }
  end

  def link_factory do
    %Radioapp.Admin.Link{
        type: Faker.Cat.En.name(),
        icon: Faker.Dog.PtBr.name()
    }
  end

  def category_factory do
    %Radioapp.Admin.Category{
        code: "1",
        name: Faker.Dog.PtBr.name(),
        segments: []
    }
  end
  def org_factory do
    %Radioapp.Accounts.Org{
      city: "Some City",
      country: "Some Country",
      email: "example@somewhere.net",
      full_name: "Some Full Name",
      short_name: "Some Short Name",
      organization: "Some Organization",
      postal_code: "Some Postal Code",
      province: "Some Province",
      telephone: "Some Telephone",
      tenant_name: "sample"
    }
  end
  def stationdefaults_factory() do
    %Radioapp.Admin.Stationdefaults{
      callsign: "CYYY",
      from_email: "some from email",
      from_email_name: "some email name",
      logo_path: "/images/radioapp_logo.png",
      org_name: "some org name",
      phone: "some phone",
      playout_url: "some playout_url",
      privacy_policy_url: "some privacy policy url",
      support_email: "some support email",
      tos_url: "some tos",
      website_url: "some website url"
    }
  end
end
