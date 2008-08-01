$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), "sinatra/lib")))
require 'rubygems'
require 'sinatra'
require 'application'

include MattPayne::Captcha
include MattPayne::Models

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

#List posts
get '/posts' do
	@posts = Post.all
	erb :posts
end

#Show post
get '/post/:id' do
	@post = Post.find(params[:id])
	erb :post
end

#New post
get '/post' do
	@post = Post.new
	erb :new_post
end

#Edit post
get '/post/:id' do
	@post = Post.find(params[:id])
	erb :edit_post
end

#Create post
post '/create/post' do
	@post = Post.new(params[:post])
	@post.save
	redirect 'posts'
end

#Update post
put '/update/post/:id' do
	@post = Post.find(params[:id])
	@post.update
	@post.save
	redirect '/posts'
end

#Delete post
delete '/post/:id' do
	Post.delete_by_id(params[:id])
	redirect '/posts'
end

#new comment
get '/new/comment/:post_id' do
	@post = Post.find(params[:post_id])
	erb :new_comment	
end

#Create comment
post "/create/comment/:post_id" do
	@comment = Comment.new(params)
	@comment.save
	redirect "/posts"
end
