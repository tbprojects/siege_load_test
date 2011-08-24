module SiegeLoadTestApplicationController

  protected
  def siege_login
    temp = request.env['HTTP_USER_AGENT'].split
    if temp[0].include? SiegeLoadTest.token
      user = User.find_by_username(temp[1])
      if request.env['warden'].present?
        # devise
        request.env['warden'].reset_session!
        request.env['warden'].set_user(user, { :scope => :user })
      else
        # default
        self.current_user = user
      end
    end
  end

end
