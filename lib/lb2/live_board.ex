defmodule Lb2.LiveBoard do
  @moduledoc """
  A running board as a process
  """
  import Ecto.Query
  alias Lb2.{Board, Card, Column}
  alias Lb2.Repo

  def create_card(column_id, content) do
    with %Column{} = col <- column_by_id(column_id),
         {:ok, card} <- do_create_card(content) do
      append_card_to_column(col, card)
    else
      nil -> {:error, "Column not found"}
    end
  end

  def append_card_to_column(%Column{} = col, %Card{} = card) do
    cards = col.cards ++ [card.id]

    with %{valid?: true} = changeset <-
           Column.changeset(col, %{cards: cards}) do
      Repo.update(changeset)
    end
  end

  defp column_by_id(column_id) do
    Repo.one(from c in Column, where: c.id == ^column_id, select: c)
  end

  defp do_create_card(content) do
    %Card{}
    |> Card.changeset(%{content: content})
    |> Repo.insert()
  end

  defp create_board(column_names) do
    column_ids = Enum.map(column_names, &create_column/1)

    data = %{name: "Test board", columns: column_ids}

    changeset = Board.changeset(%Board{}, data)

    Repo.insert(changeset)
  end

  defp create_column(name) do
    {:ok, column} =
      %Column{}
      |> Column.changeset(%{name: name})
      |> Repo.insert()

    column.id
  end
end