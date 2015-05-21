module Referrable
  extend ActiveSupport::Concern

  included do
    before_create :generate_referral_code
  end

  protected
  def generate_referral_code
    self.referral_code = loop do
      random_code = SecureRandom.urlsafe_base64(nil, false)
      break random_code unless self.class.exists?(referral_code: random_code)
    end
  end
end