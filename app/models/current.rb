# Per-request globals. The cascade: SetCurrentAccount sets `account`, Authentication sets `session`
# (which derives `identity`), and `user` is resolved as that identity's membership in that account —
# re-resolved whenever either side changes, so order of assignment doesn't matter.
class Current < ActiveSupport::CurrentAttributes
  attribute :account, :session, :identity, :user
  attribute :user_agent, :ip_address

  def session=(value)
    super
    self.identity = value&.identity
  end

  def identity=(value)
    super
    resolve_user
  end

  def account=(value)
    super
    resolve_user
  end

  private
    def resolve_user
      self.user = identity && account ? identity.users.find_by(account: account) : nil
    end
end
