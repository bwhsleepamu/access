class Authentication < ActiveRecord::Base
  # Concerns
  belongs_to :user


  def provider_name
    OmniAuth.config.camelizations[provider.to_s.downcase] || provider.to_s.titleize
  end
end