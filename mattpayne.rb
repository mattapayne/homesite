$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), "sinatra/lib")))
require 'rubygems'
require 'sinatra'
require 'application'

include MattPayne::Models
include MattPayne::Captcha
include MattPayne::Security

configure do
	enable :sessions
end

#Home page
get '/' do
	erb :home
end

#About
get '/about' do
	erb :about
end

#Contact
get '/contact' do
	erb :contact
end

#Projects
get '/projects' do
	erb :projects
end

#Services
get '/services' do
	erb :services
end

get '/login' do
	erb :login
end

post '/attempt/login' do
	if login(params["username"], params["password"])
		redirect '/'
	else
		@errors = "Invalid login."
		render :erb, :login
	end
end

get '/logout' do
	logout
	redirect '/'
end

#List posts
get '/posts' do
	@posts = Post.all
	@tags = Post.all_tags
	erb :posts
end

get '/posts/:tag' do
	@posts = Post.find_by_tag(params["tag"])
	@tags = Post.all_tags
	erb :posts
end

#Show post
get '/post/:id' do
	@post = Post.find(params["id"])
	erb :show_post
end

#New post
get '/post' do
	@post = Post.new
	@rte_required = true
	erb :new_post
end

#Edit post
get '/edit/post/:id' do
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
		render :erb, :new_post
	end
end

#Update post
put '/update/post/:id' do
	@post = Post.find(params["id"])
	@post.update_attributes(params)
	if @post.valid?
		if @post.dirty?
			@post.save
		end
		redirect "/posts"
	else
		@errors = @post.validation_errors.join("<br />")
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
	render :erb, :new_comment
end

#New comment
get '/new/comment/:post_id' do
	@post = Post.find(params["post_id"])
	@comment = Comment.new(:post_id => @post.id)
	@rte_required = true
	erb :new_comment	
end

#Create comment
post "/create/comment/:post_id" do
	@comment = Comment.new(params)
	errors = @comment.validation_errors || []
	puts "COMMENT: #{@comment.inspect}"
	errors << "Invalid captcha. Please try again." unless captcha_valid?(params.delete("captcha"))
	puts "ERRORS: #{errors.inspect}"
	if errors.empty?
		@comment.save
		redirect "/posts"
	else
		@errors = errors.join("<br />")
		@rte_required = true
		render :erb, :new_comment
	end
end
