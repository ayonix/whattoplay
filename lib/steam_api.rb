class SteamApi
  class << self
    def get_owned_games(steamid)
      uri = URI("https://api.steampowered.com/IPlayerService/GetOwnedGames/v1/?key=#{ENV['STEAM_WEB_API_KEY']}&steamid=#{steamid}&include_appinfo=1")
      json = JSON.parse(Net::HTTP.get(uri))["response"]
      if json.empty?
        return {}
      else
        return json["games"]
      end
    end 

    def get_owned_game_ids(steamid)
      json = get_owned_games(steamid)
      json.map{|hsh| hsh.select {|k,v| k == "appid"}.values}.flatten
    end

    def get_friend_list(steamid)
      uri = URI("https://api.steampowered.com/ISteamUser/GetFriendList/v1/?key=#{ENV['STEAM_WEB_API_KEY']}&steamid=#{steamid}")
      json = JSON.parse(Net::HTTP.get(uri))
      if json.empty?
        return {}
      else
        return json["friendslist"]["friends"]
      end
    end

    def get_friend_summaries(steamids)
      ids = steamids.join(',')
      uri = URI("https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v2/?key=#{ENV['STEAM_WEB_API_KEY']}&steamids=#{ids}")
      json = JSON.parse(Net::HTTP.get(uri))["response"]

      if json.empty?
        return []
      else
        return json["players"]
      end
    end

    # appids - array of ids
    def get_game_info(appids)
      # only fetch ids that are not in database already
      appids = appids - SteamApp.pluck(:steam_appid)
      ids = appids.join(',')

      # get the information to the games and parse the json
      if ids.size > 0
        uri = URI("https://store.steampowered.com/api/appdetails/?appids=#{ids}&cc=EE&l=english&v=1")
        json = JSON.parse(Net::HTTP.get(uri))

        json.each do |app|
          if app.last.delete "success"
            data = app.last["data"]
            data["steam_appid"] = data["steam_appid"].to_i
            SteamApp.create(data)
          end
        end
      end
    end

    def find_coop_games(steamids, categoryids)
      app_ids = Hash.new
      games = []

      # find the intersection
      steamids.each do |id|
        app_ids[id] = get_owned_game_ids(id)
        if games.empty?
          games = app_ids[id] 
        else
          games &= app_ids[id]
        end
      end

      # fetch them to the database
      get_game_info(games)
      if categoryids.nil?
        return SteamApp.where(:steam_appid.in => games)
      else
        return SteamApp.where(:steam_appid.in => games).where(:"categories.id".in => categoryids)
      end
    end

    def get_app_image_url(appid, image_url)
      "http://media.steampowered.com/steamcommunity/public/images/apps/#{appid}/#{image_url}.jpg"
    end
  end
end
