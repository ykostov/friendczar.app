defmodule Friendczar.Authentication.PersonToken do
  use Ecto.Schema
  import Ecto.Query

  @hash_algorithm :sha256
  @rand_size 32

  # It is very important to keep the reset password token expiry short,
  # since someone with access to the email may take over the account.
  @reset_password_validity_in_days 1
  @confirm_validity_in_days 7
  @change_email_validity_in_days 7
  @session_validity_in_days 60

  schema "persons_tokens" do
    field :token, :binary
    field :context, :string
    field :sent_to, :string
    belongs_to :person, Friendczar.Authentication.Person

    timestamps(updated_at: false)
  end

  @doc """
  Generates a token that will be stored in a signed place,
  such as session or cookie. As they are signed, those
  tokens do not need to be hashed.
  """
  def build_session_token(person) do
    token = :crypto.strong_rand_bytes(@rand_size)
    {token, %Friendczar.Authentication.PersonToken{token: token, context: "session", person_id: person.id}}
  end

  @doc """
  Checks if the token is valid and returns its underlying lookup query.

  The query returns the person found by the token.
  """
  def verify_session_token_query(token) do
    query =
      from token in token_and_context_query(token, "session"),
        join: person in assoc(token, :person),
        where: token.inserted_at > ago(@session_validity_in_days, "day"),
        select: person

    {:ok, query}
  end

  @doc """
  Builds a token with a hashed counter part.

  The non-hashed token is sent to the person email while the
  hashed part is stored in the database, to avoid reconstruction.
  The token is valid for a week as long as persons don't change
  their email.
  """
  def build_email_token(person, context) do
    build_hashed_token(person, context, person.email)
  end

  defp build_hashed_token(person, context, sent_to) do
    token = :crypto.strong_rand_bytes(@rand_size)
    hashed_token = :crypto.hash(@hash_algorithm, token)

    {Base.url_encode64(token, padding: false),
     %Friendczar.Authentication.PersonToken{
       token: hashed_token,
       context: context,
       sent_to: sent_to,
       person_id: person.id
     }}
  end

  @doc """
  Checks if the token is valid and returns its underlying lookup query.

  The query returns the person found by the token.
  """
  def verify_email_token_query(token, context) do
    case Base.url_decode64(token, padding: false) do
      {:ok, decoded_token} ->
        hashed_token = :crypto.hash(@hash_algorithm, decoded_token)
        days = days_for_context(context)

        query =
          from token in token_and_context_query(hashed_token, context),
            join: person in assoc(token, :person),
            where: token.inserted_at > ago(^days, "day") and token.sent_to == person.email,
            select: person

        {:ok, query}

      :error ->
        :error
    end
  end

  defp days_for_context("confirm"), do: @confirm_validity_in_days
  defp days_for_context("reset_password"), do: @reset_password_validity_in_days

  @doc """
  Checks if the token is valid and returns its underlying lookup query.

  The query returns the person token record.
  """
  def verify_change_email_token_query(token, context) do
    case Base.url_decode64(token, padding: false) do
      {:ok, decoded_token} ->
        hashed_token = :crypto.hash(@hash_algorithm, decoded_token)

        query =
          from token in token_and_context_query(hashed_token, context),
            where: token.inserted_at > ago(@change_email_validity_in_days, "day")

        {:ok, query}

      :error ->
        :error
    end
  end

  @doc """
  Returns the given token with the given context.
  """
  def token_and_context_query(token, context) do
    from Friendczar.Authentication.PersonToken, where: [token: ^token, context: ^context]
  end

  @doc """
  Gets all tokens for the given person for the given contexts.
  """
  def person_and_contexts_query(person, :all) do
    from t in Friendczar.Authentication.PersonToken, where: t.person_id == ^person.id
  end

  def person_and_contexts_query(person, [_ | _] = contexts) do
    from t in Friendczar.Authentication.PersonToken, where: t.person_id == ^person.id and t.context in ^contexts
  end
end
