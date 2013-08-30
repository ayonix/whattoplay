class SteamController < ApplicationController
  before_action :authenticate_user!, only: [:find_games, :index]
  before_action :set_stuff, only: [:index]

  def index
  end

  def find_games
    users = [] 
    users += params[:friends] unless params[:friends].nil?
    users << current_user.steam_id
    @games = SteamApi.find_coop_games(users, params[:categories]).sort_by {|g| g.name} 
    @owned_games = SteamApi.get_owned_games(current_user.steam_id).map{|a| {a.delete("appid") => a}}.inject(:merge)

    respond_to do |format|
      format.js { render 'find_games', :locals => {:owned_games => @owned_games}}
      format.html { render 'index'}
      format.json {}
    end
  end

  def privacy
  end

  private 
  def set_stuff
    @friend_list ||= SteamApi.get_friend_list(current_user.steam_id) 
    @friends ||= SteamApi.get_friend_summaries(@friend_list.map{|f| f["steamid"]})
    @categories ||= SteamApp.pluck(:categories).flatten.uniq.map{|c| [c["description"], c["id"]]}
  end
end
