class User < ActiveRecord::Base

  # Include default devise modules. Others available are:
  # :confirmable, :lockable and :omniauthable
  devise :database_authenticatable, :timeoutable, :registerable
  devise :omniauthable, :omniauth_providers => [:ldap]

  ##
  # Associations
  has_many :authentications
  has_many :projects
  has_many :sources
  has_many :documentations

  ##
  # Concerns
  include Deletable

  ##
  # Constants
  STATUS = ["active", "denied", "inactive", "pending"].collect{|i| [i,i]}

  ##
  # Devise

  # Include default devise modules. Others available are:
  # :confirmable, :lockable and :omniauthable
  devise :database_authenticatable, :timeoutable
  #  :database_authenticatable, :registerable, :timeoutable,
  #    :recoverable, :rememberable, :trackable, :validatable, :token_authenticatable

  ##
  # Scopes
  scope :search, lambda { |*args| { conditions: [ 'LOWER(first_name) LIKE ? or LOWER(last_name) LIKE ? or LOWER(email) LIKE ?', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%' ] } }
  scope :system_admins, -> { where( system_admin: true ) }
  scope :status, lambda { |*args|  { conditions: ["users.status IN (?)", args.first] } }

  ##
  # Validations
  validates_presence_of :email


  ##
  # Instance Methods
  def avatar_url(size = 80, default = 'mm')
    gravatar_id = Digest::MD5.hexdigest(self.email.downcase)
    "//gravatar.com/avatar/#{gravatar_id}.png?&s=#{size}&r=pg&d=#{default}"
  end

  # Overriding Devise built-in active_for_authentication? method
  def active_for_authentication?
    super and self.status == 'active' and not self.deleted?
  end

  def name
    "#{first_name} #{last_name}"
  end

  def reverse_name
    "#{last_name}, #{first_name}"
  end

  def all_subjects
    Subject.current
  end

  def apply_omniauth(omniauth)
    unless omniauth['info'].blank?
      self.first_name = omniauth['info']['first_name'] if first_name.blank?
      self.last_name = omniauth['info']['last_name'] if last_name.blank?
      self.email = omniauth['info']['email'] if email.blank?
    end
    self.password = Devise.friendly_token[0,20] if self.password.blank?
    authentications.build( provider: omniauth['provider'], uid: omniauth['uid'] )
  end

=begin

require 'net/ldap'
auth = {method: :simple, username: 'Partners\pwm4', password: '1ostatniehaslo'}
ops = {encryption: {method: :simple_tls, tls_options: OpenSSL::SSL::SSLContext::DEFAULT_PARAMS}, host: "ldap.partners.org", port: 636, base: 'cn=users,dc=partners,dc=org', auth: auth}
ldap = Net::LDAP.new(ops)
ldap.bind


=end

  private

end
