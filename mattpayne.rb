require File.join(File.dirname(__FILE__), 'src/loader')

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
  set :connection_string => MattPayne::Config.connection_string
end

configure :development do
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
    @post.save
    redirect '/blog'
  else
    @errors = @post.validation_errors.join("<br />")
    @title = " - Create Post"
    erb :new_post
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
    @captcha = MattPayne::Captcha.new
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
  supplied_captcha = params.delete("captcha")
  random = params.delete("random")
  @comment = Comment.new(params.merge(:post_id => @post.id))
  errors = @comment.validation_errors || []
  unless MattPayne::Captcha.valid?(random, supplied_captcha)
    errors << "Invalid captcha. Please try again." 
  end
  unless MattPayne::AK.valid_comment?(@comment, {
        :ip => user_ip, :referrer => user_referrer, :user_agent => user_agent, :blog => blog_url}
    )
    errors << "Your comment appears to be spam. Please try again."
  end
  if errors.empty?
    @comment.save
    redirect "/blog"
  else
    @errors = errors.join("<br />")
    @rte_required = true
    @title = " - Add Comment"
    @captcha = MattPayne::Captcha.new
    erb :new_comment
  end
end
