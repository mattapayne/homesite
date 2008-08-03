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
	erb :posts
end

#Show post
get '/post/:id' do
	@post = Post.find(params["id"])
	erb :post
end

#New post
get '/post' do
	@post = Post.new({})
	erb :new_post
end

#Edit post
get '/edit/post/:id' do
	@post = Post.find(params["id"])
	erb :edit_post
end

#Create post
post '/create/post' do
	@post = Post.new(params)
	@post.save
	redirect '/posts'
end

#Update post
put '/update/post/:id' do
	@post = Post.find(params["id"])
	@post.update_attributes(params)
	@post.save if @post.dirty?
	redirect '/posts'
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
	render :erb, :new_comment
end

#New comment
get '/new/comment/:post_id' do
	@post = Post.find(params["post_id"])
	@comment = Comment.new(:post_id => @post.id)
	erb :new_comment	
end

#Create comment
post "/create/comment/:post_id" do
	@comment = Comment.new(params)
	errors = []
	errors << "Invalid captcha. Please try again." unless captcha_valid?(params.delete("captcha"))
	errors << "You must supply a comment." if (@comment.comment.nil? || @comment.comment == "")
	if errors.empty?
		@comment.save
		redirect "/posts"
	else
		@errors = errors.join("<br />")
		render :erb, :new_comment
	end
end
