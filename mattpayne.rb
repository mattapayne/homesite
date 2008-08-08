local_path = File.expand_path(File.dirname(__FILE__))
vendor_path = File.expand_path(File.join(File.dirname(__FILE__), "vendor", "sinatra", "lib"))

$:.unshift(local_path) unless $:.include?(local_path)
$:.unshift(vendor_path) unless $:.include?(vendor_path)

require 'rubygems'
require 'sinatra'
require 'src/core_extensions'
require 'src/config'
require 'src/tumblr'
require 'src/github'
require 'src/blog_to_rss'
require 'src/database'
require 'src/models'
require 'src/captcha'
require 'src/html_tags'
require 'src/security'
require 'src/helpers'

configure :production do
	set :connection_string => "mysql://root:2324@localhost/mattpayne"
end

configure :test do
	set :connection_string => "mysql://root:2324@localhost/mattpayne_test"
end

configure :development do
	set :connection_string => "mysql://root:2324@localhost/mattpayne_dev"
end

include MattPayne::Models

@@tracked_requests = ["/", "/projects", "/services", "/about", "/contact", "/posts"]
		
before do
	request_path = request.env["REQUEST_PATH"]
	if @@tracked_requests.include?(request_path)
		begin
			ip_address = request.env["REMOTE_ADDR"]
			user_agent = request.env["HTTP_USER_AGENT"]
			session_id = request.env["rack.request.cookie_hash"]["rack.session"]
			Hit.new(
				:ip_address => ip_address, :user_agent => user_agent, :session_id => session_id
			).save
		rescue
			#Swallow the error
		end
	end
end

#Home page
get '/' do
	@title = " - Home"
	erb :home
end

#About
get '/about' do
	@title = " - About"
	erb :about
end

#Contact
get '/contact' do
	@title = " - Contact"
	erb :contact
end

#Projects
get '/projects' do
	@title = " - Projects"
	erb :projects
end

#Services
get '/services' do
	@title = " - Services"
	erb :services
end

get '/login' do
	@title = " - Login"
	erb :login
end

post '/attempt/login' do
	if login(params["username"], params["password"])
		redirect '/'
	else
		@errors = "Invalid login."
		@title = " - Login"
		render :erb, :login
	end
end

get '/logout' do
	logout
	redirect '/'
end

#list hits
get "/hits" do
	@hits = Hit.all
	erb :hits
end

#List posts
get '/posts' do
	@title = " - Blog"
	@posts = Post.paged(5, params["page"])
	load_blog_variables
	@tagged = false
	@requires_highlighting = @posts.map {|p| p.contains_code?}.size > 0
	erb :posts
end

#Get posts as RSS
get '/posts/posts.rss' do
	Post.to_rss
end

get '/posts/tag/:tag' do
	@title = " - Blog - (#{params["tag"]}) Posts"
	@posts = Post.find_by_tag(params["tag"], 5, params["page"])
	load_blog_variables
	@tagged = true
	@requires_highlighting = @posts.map {|p| p.contains_code?}.size > 0
	erb :posts
end

#Show post
get '/post/:id' do
	@title = " - Post Details"
	@post = Post.find(params["id"])
	load_blog_variables
	@requires_highlighting = @post.contains_code?
	erb :show_post
end

#New post
get '/post' do
	@title = " - Create Post"
	@post = Post.new
	@rte_required = true
	erb :new_post
end

#Edit post
get '/edit/post/:id' do
	@title = " - Edit Post"
	@post = Post.find(params["id"])
	@rte_required = true
	erb :edit_post
end

#Create post
post '/create/post' do
	@post = Post.new(params)
	if @post.valid?
		@post.save
		redirect '/posts'
	else
		@errors = @post.validation_errors.join("<br />")
		@title = " - Create Post"
		render :erb, :new_post
	end
end

#Update post
put '/update/post/:id' do
	@post = Post.find(params["id"])
	@post.update_attributes(params)
	if @post.valid?
		@post.save if @post.dirty?
		redirect "/posts"
	else
		@errors = @post.validation_errors.join("<br />")
		@rte_required = true
		@title = " - Edit Post"
		render :erb, :edit_post
	end
end

#Delete post
	delete '/post/:id' do
	Post.delete_by_id(params["id"])
	redirect '/posts'
end

#New captcha'd comment
get '/new/comment/reload/captcha/:post_id' do
	@post = Post.find(params["post_id"])
	@comment = Comment.new(:post_id => @post.id)
	@rte_required = true
	@title = " - Add Comment"
	render :erb, :new_comment
end

#New comment
get '/new/comment/:post_id' do
	@title = " - Add Comment"
	@post = Post.find(params["post_id"])
	@comment = Comment.new(:post_id => @post.id)
	@rte_required = true
	erb :new_comment	
end

#Create comment
post "/create/comment/:post_id" do
	@comment = Comment.new(params)
	errors = @comment.validation_errors || []
	errors << "Invalid captcha. Please try again." unless captcha_valid?(params.delete("captcha"))
	if errors.empty?
		@comment.save
		redirect "/posts"
	else
		@post = Post.find(params["post_id"])
		@errors = errors.join("<br />")
		@rte_required = true
		@title = " - Add Comment"
		render :erb, :new_comment
	end
end

private

def load_blog_variables
	@tags ||= Post.all_tags
	@tumblr_posts ||= MattPayne::Tumblr.posts
	@github_repos ||= MattPayne::GitHub.repositories
end
