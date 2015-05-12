class PasswordReset
  include ActiveModel::Conversion
  include ActiveModel::Validations
  extend ActiveModel::Naming

  PASSWORD_TOKEN_TTL = 4.hours

  attr_reader :email

  validates :email, presence: { message: I18n.t('password_resets.errors.email.blank') }
  validate :account_exists_for_email, if: -> { email.present? }

  def initialize(attributes = {})
    attributes.each do |name, value|
      instance_variable_set("@#{ name }", value)
    end
  end

  # NOTE: Replaces init_reset_password!
  def refresh_token_and_email_link
    token = SecureRandom.hex(16)
    account.reset_password_tokens ||= {}
    account.reset_password_tokens[token] = Time.now.utc + PASSWORD_TOKEN_TTL

    # FIXME: Integrate this mailer action and view.
    # AccountNotifier.reset_password_link(account, token).deliver

    account.save!
  end

  def persisted?
    false
  end

  private

  def account
    @account ||= Account.find_by(email: email.strip)
  end

  def account_exists_for_email
    return if account

    errors.add(:email, I18n.t('password_resets.errors.account.invalid'))
  end
end