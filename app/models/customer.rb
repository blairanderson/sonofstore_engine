class Customer < ActiveRecord::Base
  authenticates_with_sorcery!

  has_one :cart

  validates_confirmation_of :password, message: "Password should match confirmation.", if: :password
end