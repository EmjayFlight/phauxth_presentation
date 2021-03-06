defmodule MaySecondWeb.UserControllerTest do
  use MaySecondWeb.ConnCase

  import MaySecondWeb.AuthCase
  alias MaySecond.Accounts
  @create_attrs %{first_name: "Billiam", last_name: "Clinton", email: "bill@example.com", secret: "Too many to mention, probably", role: "Seller", password: "hard2guess"}
  @admin_attrs %{first_name: "Admin", last_name: "McAdminson", email: "admin@example.com", secret: "I chew gum to prevent my double chin",  role: "Seller",  password: "password", admin: true}
  @update_attrs %{email: "william@example.com"}
  @invalid_attrs %{email: nil}

  setup %{conn: conn} = config do
    conn = conn |> bypass_through(MaySecondWeb.Router, [:browser]) |> get("/")
    if email = config[:login] do
      user = add_user("tony", "stark", "tony@example.com", "I'm jelly of Captain America", "Buyer", "password")
      other = add_user("steve", "rogers", "sr@example.com", "I am pretty kewl", "Seller", "password")
      conn = conn |> add_phauxth_session(user) |> send_resp(:ok, "/")
      {:ok, %{conn: conn, user: user, other: other}}
    else
      {:ok, %{conn: conn}}
    end
  end

  test "renders form for new users", %{conn: conn} do
    conn = get(conn, user_path(conn, :new))
    assert html_response(conn, 200) =~ "New User"
  end

  @tag login: "reg@example.com"
  test "show chosen user's page", %{conn: conn, user: user} do
    conn = get(conn, user_path(conn, :show, user))
    assert html_response(conn, 200) =~ "Show User"
  end

  test "creates user when data is valid", %{conn: conn} do
    conn = post(conn, user_path(conn, :create), user: @create_attrs)
    assert redirected_to(conn) == session_path(conn, :new)
  end

  @tag login: "reg@example.com"
  test "renders form for editing chosen user", %{conn: conn, user: user} do
    conn = get conn,(user_path(conn, :edit, user))
    assert html_response(conn, 200) =~ "Edit User"
  end

  @tag login: "reg@example.com"
  test "updates chosen user when data is valid", %{conn: conn, user: user} do
    conn = put(conn, user_path(conn, :update, user), user: @update_attrs)
    assert redirected_to(conn) == user_path(conn, :show, user)
    updated_user = Accounts.get(user.id)
    assert updated_user.email == "william@example.com"
    conn = get conn,(user_path(conn, :show, user))
    assert html_response(conn, 200) =~ "william@example.com"
  end

  @tag login: "reg@example.com"
  test "cannot delete other user", %{conn: conn, other: other} do
    conn = delete(conn, user_path(conn, :delete, other))
    assert redirected_to(conn) == user_path(conn, :index)
    assert Accounts.get(other.id)
  end
end
