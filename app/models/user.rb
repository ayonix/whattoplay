class User
  include Mongoid::Document
  field :steam_id, type: String
  field :remember_token, type: String

  def User.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def User.encrypt(token)
    Digest::SHA1.hexdigest(token.to_s)
  end
  private 
  
  def create_remember_token
    self.remember_token = User.encrypt(User.new_remember_token)
  end

end
