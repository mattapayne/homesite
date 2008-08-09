module MattPayne
	
	module Security
		
		def login(username, password)
			if ((username == MattPayne::Config.admin_username) && 
				(password == MattPayne::Config.admin_password))
					session[:logged_in] = true
					return true
			end
			return false
		end
		
		def logout
			session.delete(:logged_in)
		end
		
		def logged_in?
			!session[:logged_in].nil? && session[:logged_in] == true
		end
		
		def require_login
			throw :halt, [401, 'Authorization Required'] unless logged_in?
		end
		
	end
	
end
