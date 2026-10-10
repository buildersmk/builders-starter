# A Session is a signed-in browser, tied to the global Identity (not a per-account User). The current
# per-account User is derived per request from the Identity + the resolved Account (see Current).
class CreateSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :sessions do |t|
      t.references :identity, null: false, foreign_key: true
      t.string :ip_address
      t.string :user_agent

      t.timestamps
    end
  end
end
