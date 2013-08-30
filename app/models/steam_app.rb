class SteamApp
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic
  validates :steam_appid, uniqueness: true
  
  field :type 
  field :steam_appid
  field :categories
  field :header_image
  field :name
end
