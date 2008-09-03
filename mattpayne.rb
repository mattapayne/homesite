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
	
  not_found do
    "We're so sorry, but we don't what this is"
  end

  error do
    "Something really nasty happened.  We're on it!"
  end

end

configure :test do
  set :connection_string => "mysql://root:2324@localhost/mattpayne_test"
end

configure :development do
  set :connection_string => "mysql://root:2324@localhost/mattpayne_dev"
end

include MattPayne::Models

helpers do	
  include MattPayne::Helpers
end

#Home page
get '/' do
  @title = " - Home"
  @action = "home"
  erb :home
end

#About
get '/about' do
  @title = " - About"
  @action = "about"
  erb :about
end

#Contact
get '/contact' do
  @title = " - Contact"
  @action = "contact"
  @render_gmh = true
  erb :contact
end

#Projects
get '/projects' do
  @title = " - Projects"
  @action = "projects"
  erb :projects
end

#Services
get '/services' do
  @title = " - Services"
  @action = "services"
  erb :services
end

get '/login' do
  @title = " - Login"
  @action = "login"
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

#List posts
get '/blog' do
  @posts = Post.paged(5, params["page"])
  load_blog_variables
  @title = " - Blog"
  @tagged = false
  @action = "blog"
  @requires_highlighting = @posts.select {|p| p.contains_code?}.not_empty?
  erb :posts
end

#Get posts as RSS
get '/blog/posts.rss' do
  Post.to_rss
end

get '/blog/posts/tagged-as/:tag' do
  @posts = Post.find_by_tag(params["tag"], 5, params["page"])
  load_blog_variables
  @title = " - Blog - Posts Tagged As (#{params["tag"].capitalize})"
  @tagged = true
  @action = "blog"
  @requires_highlighting = @posts.select {|p| p.contains_code?}.not_empty?
  erb :posts
end

#Show post
get '/blog/post/:slug' do
  @post = Post.find_by_slug(params["slug"])
  raise_post_not_found(params["slug"]) unless @post
  load_blog_variables
  @title = " - Post Details"
  @action = "blog"
  @requires_highlighting = @post.contains_code?
  erb :show_post
end

#New post
get '/blog/post' do
  require_login
  @post = Post.new
  @title = " - Create Post"
  @action = "blog"
  @rte_required = true
  erb :new_post
end

#Edit post
get '/blog/edit/post/:slug' do
  require_login
  @post = Post.find_by_slug(params["slug"])
  raise_post_not_found(params["slug"]) unless @post
  @title = " - Edit Post"
  @action = "blog"
  @rte_required = true
  erb :edit_post
end

#Create post
post '/blog/create/post' do
  require_login
  @post = Post.new(params)
  if @post.valid?
    @post.save
    redirect '/blog'
  else
    @errors = @post.validation_errors.join("<br />")
    @title = " - Create Post"
    render :erb, :new_post
  end
end

#Update post
put '/blog/update/post/:slug' do
  require_login
  @post = Post.find_by_slug(params["slug"])
  raise_post_not_found(params["slug"]) unless @post
  @post.update_attributes(params)
  if @post.valid?
    @post.save if @post.dirty?
    redirect "/blog"
  else
    @errors = @post.validation_errors.join("<br />")
    @rte_required = true
    @title = " - Edit Post"
    render :erb, :edit_post
  end
end

#Delete post
delete '/blog/delete/post/:slug' do
  require_login
  @post = Post.find_by_slug(params["slug"])
  raise_post_not_found(params["slug"]) unless @post
  @post.delete
  redirect '/blog'
end

#New captcha'd comment
get '/blog/new/comment/reload/captcha/:slug' do
  @post = Post.find_by_slug(params["slug"])
  raise_post_not_found(params["slug"]) unless @post
  @comment = Comment.new(:post_id => @post.id)
  @rte_required = true
  @title = " - Add Comment"
  @action = "blog"
  render :erb, :new_comment
end

#New comment
get '/blog/new/comment/:slug' do
  @post = Post.find_by_slug(params["slug"])
  raise_post_not_found(params["slug"]) unless @post
  @comment = Comment.new(:post_id => @post.id)
  @title = " - Add Comment"
  @rte_required = true
  @action = "blog"
  erb :new_comment	
end

#Create comment
post "/blog/create/comment/:slug" do
  @post = Post.find_by_slug(params["slug"])
  raise_post_not_found(params["slug"]) unless @post
  @comment = Comment.new(params.merge(:post_id => @post.id))
  errors = @comment.validation_errors || []
  unless captcha_valid?(params.delete("captcha"))
    errors << "Invalid captcha. Please try again." 
  end
  if errors.empty?
    @comment.save
    redirect "/blog"
  else
    @errors = errors.join("<br />")
    @rte_required = true
    @title = " - Add Comment"
    render :erb, :new_comment
  end
end

private

def raise_post_not_found(id)
  raise Sinatra::NotFound.new("Could not find a post identified by: #{id}")
end

def load_blog_variables
  @tags ||= Post.all_tags
  @tumblr_posts ||= MattPayne::Tumblr.posts
  @github_repos ||= MattPayne::GitHub.repositories
end
