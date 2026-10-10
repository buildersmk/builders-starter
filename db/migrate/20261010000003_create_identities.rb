# An Identity is a person's global login — one email, one passwordless identity — independent of any
# Account. It holds the 6-digit login-code state and owns the sessions. One Identity can be a User in
# many Accounts (see users).
class CreateIdentities < ActiveRecord::Migration[8.1]
  def change
    create_table :identities do |t|
      t.string :email_address, null: false
      t.datetime :email_confirmed_at

      # Passwordless 6-digit login code: the code is bcrypt-hashed into login_code_digest, time-boxed
      # by login_code_sent_at, and attempt-locked by login_code_attempts.
      t.string :login_code_digest
      t.datetime :login_code_sent_at
      t.integer :login_code_attempts, null: false, default: 0

      t.timestamps
    end

    add_index :identities, :email_address, unique: true
  end
end
