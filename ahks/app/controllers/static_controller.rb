class StaticController < ApplicationController

def index
	@nav_select = "home"
end

def dashboard

end

def subscription

	if !params[:email].nil?
		file_path = Rails.root.to_s + "/email_list"
		fp = File.open(file_path, "r")
		text = fp.read
		fp.close
		fp = File.open(file_path, "w")
		text = text + params[:email] + "\n"
		fp.write(text)
		fp.close
	end


	redirect_to "/"

end

def plans
	@nav_select = "plans"
end

def about
	@nav_select = "about"
end

end
