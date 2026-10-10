# A User is the membership of an Identity inside one Account — it carries the per-account name and
# role. (The global login lives on Identity; the account-scoped "who are you here" lives on User.)
class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.references :account, null: false, foreign_key: true
      t.references :identity, foreign_key: true
      t.string :name, null: false
      t.string :role, null: false, default: "member" # member | admin | owner

      t.timestamps
    end

    add_index :users, [ :account_id, :identity_id ], unique: true
  end
end
