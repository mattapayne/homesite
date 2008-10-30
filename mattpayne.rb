require File.join(File.dirname(__FILE__), 'src/loader')

configure do
  RDefensio::API.configure do |conf|
    conf.api_key = MattPayne::Config.defensio_api_key
    conf.owner_url = MattPayne::Config.defensio_owner_url
  end
end

configure :production do
  set :connection_string => MattPayne::Config.connection_string
	
  not_found do
    "We're so sorry, but we don't what this is"
  end

  error do
    "Something really nasty happened.  We're on it!"
  end

end

configure :test do
  set :sessions => true
  set :connection_string => MattPayne::Config.connection_string
end

configure :development do
  set :sessions => true
  set :connection_string => MattPayne::Config.connection_string
end

include MattPayne::Models

helpers do	
  include MattPayne::Helpers, MattPayne::ControllerHelpers
end

#Home page
get '/' do
  for_simple_action() do
    erb :home
  end
end

#About
get '/about' do
  for_simple_action(:action => "about") do
    erb :about
  end
end

#Contact
get '/contact' do
  for_simple_action(:action => "contact", :render_gmh => true) do
    erb :contact
  end
end

#Projects
get '/projects' do
  for_simple_action(:action => "projects") do
    erb :projects
  end
end

#Services
get '/services' do
  for_simple_action(:action => "services") do
    erb :services
  end
end

get '/login' do
  for_simple_action(:action => "login") do
    erb :login
  end
end

post '/attempt/login' do
  sleep(3)
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
  for_blog_related_action() do
    @posts = Post.paged(5, params["page"] || "1")
    @requires_highlighting = @posts.select {|p| p.contains_code?}.not_empty?
    erb :posts
  end
end

#Get posts as RSS
get '/blog/posts.rss' do
  Post.to_rss
end

get '/blog/posts/search' do
  for_blog_related_action(:searched => true, :title => " - Blog - Posts For #{params['query']}") do
    #handle js disabled. This will simply render the error message to the page.
    ensure_param(!params['query'].blank?, "**You must enter a search value**<br />")
    ensure_param((!params['query'].blank? && params['query'].size >= 4), 
      "**You must enter a search value of at least 4 characters**<br />")
    @posts = Post.search(params["query"], 5, params["page"] || "1")
    @requires_highlighting = @posts.select {|p| p.contains_code?}.not_empty?
    @query = params['query']
    erb :posts
  end
end

get '/blog/posts/tagged-as/:tag' do
  for_blog_related_action(:tagged => true, :title => " - Blog - Posts Tagged As (#{params["tag"].capitalize})") do
    @posts = Post.find_by_tag(params["tag"], 5, params["page"] || "1")
    @requires_highlighting = @posts.select {|p| p.contains_code?}.not_empty?
    erb :posts
  end
end

#Show post
get '/blog/post/:slug' do
  for_blog_related_action(:title => " - Post Details") do
    @post = Post.find_by_slug(params["slug"])
    @requires_highlighting = @post.contains_code?
    erb :show_post
  end
end

#New post
get '/blog/post' do
  for_blog_related_action(:secure => true, :title => " - Create Post", :rte_required => true) do
    @post = Post.new
    erb :new_post
  end
end

#Edit post
get '/blog/edit/post/:slug' do
  for_blog_related_action(:secure => true, :title => @title = " - Edit Post", :rte_required => true) do
    @post = Post.find_by_slug(params["slug"])
    raise_post_not_found(params["slug"]) unless @post
    erb :edit_post
  end
end

#Create post
post '/blog/create/post' do
  require_login
  @post = Post.new(params)
  if @post.valid?
    results = submit_post(@post)
    if results.status == "success"
      @post.announced = true
      @post.save
      redirect '/blog' and return
    end
  end
  @errors = @post.validation_errors.join("<br />")
  @title = " - Create Post"
  erb :new_post
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
    erb :edit_post
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

#New comment
get '/blog/new/comment/:slug' do
  for_blog_related_action(:title => " - Add Comment", :rte_required => true) do
    @post = Post.find_by_slug(params["slug"])
    raise_post_not_found(params["slug"]) unless @post
    @comment = Comment.new(:post_id => @post.id)
    erb :new_comment	
  end
end

#Create comment
post "/blog/create/comment/:slug" do
  @post = Post.find_by_slug(params["slug"])
  raise_post_not_found(params["slug"]) unless @post
  @comment = Comment.new(params.merge(:post_id => @post.id))
  errors = @comment.validation_errors || []
  #Make sure there are no validation errors
  if errors.empty?
    #Submit to Defensio
    audit_results = submit_comment(@comment, params["spam"], params["ham"])
    #Set the Defensio values
    @comment.signature = audit_results.signature
    @comment.spam = audit_results.spam
    @comment.spaminess = audit_results.spaminess
    @comment.api_version = audit_results.api_version
    if @comment.possibly_spam?
      @comment.reviewed = false
    else
      @comment.reviewed = true
    end
    @comment.save
    #If the comment requires review, render the comment submitted view
    if @comment.possibly_spam?
      @title = " - Comment Submitted"
      @action = "blog"
      erb :comment_submitted
    else
      redirect "/blog"
    end
  else
    @errors = errors.join("<br />")
    @rte_required = true
    @title = " - Add Comment"
    erb :new_comment
  end
end

#See all comments
get "/blog/comments" do
  for_blog_related_action(:secure => true, :title => " - Manage Comments", :action => "comments") do
    @comments = Comment.all_by_spaminess
    erb :comments
  end
end

get "/blog/comments/stats" do
  for_blog_related_action(:secure => true, :title => " - Comment Statistics", :action => "stats") do
    @stats = RDefensio::API.get_stats
    erb :stats
  end
end

post "/blog/comments/mark-as-spam" do
  require_login
  @comment = Comment.find_by_signature(params["signature"])
  result = RDefensio::API.report_false_negatives(@comment.signature)
  if result.status == "success"
    @comment.reviewed = true
    @comment.spam = true
    @comment.save
  end
  redirect "/blog/comments"
end

post "/blog/comments/mark-as-not-spam" do
  require_login
  @comment = Comment.find_by_signature(params["signature"])
  result = RDefensio::API.report_false_positives(@comment.signature)
  if result.status == "success"
    @comment.reviewed = true
    @comment.spam = false
    @comment.save
  end
  redirect "/blog/comments"
end
