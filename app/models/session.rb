# A signed-in browser, tied to the global Identity. The per-account User is derived per request (Current).
class Session < ApplicationRecord
  belongs_to :identity
end
