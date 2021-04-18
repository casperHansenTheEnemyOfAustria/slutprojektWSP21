
require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'rails'
require 'byebug'
require_relative("./model.rb")
enable :sessions

salt = "awoogamonke"



include Model

# login functions

# Displays landing page
#
get("/"){
    session[:time] = ""
    session[:message] = ""
    if session[:loggedIn] == nil
      session[:loggedIn] = false
    end
    session[:ipAdress] = request.ip
    # Logs peoples ip adress for saving usernames
    print "this is your ip adress #{request.ip}"
    slim(:index)
}
attempts = 0
# Displays custom success messages
#
get("/success"){
  slim(:success)
}

# Displays custom fail messages
#
get("/fail"){
  slim(:fail )
} 

# Logs user in
#
# @param [String] username
# @param [String] password
# @see Model#loginFunc
post("/login"){
    if session[:tooMany] == false
      p "reset attempts"
      attempts = 0 
      session[:tooMany] = nil
    end
    username = params[:username]
    password = params[:password] + salt
    p "running login function"
    if loginFunc(username, password)
      p "managed to log in "
      # Sets the session username to the correct ones for further use
      session[:username] = username
      # Finds the id
      session[:id] = getId(username)
      # Makes sure the site knows youre logged in
      session[:loggedIn] = true

      # Checks for admin priviliges
      if admin(username)
        session[:admin] = true
      end
      # Gets all the user posts and their info
      session[:postInfo] = checkPosts(session[:id])
      redirect("users/index")
          
    else
      # Makes sure it doesnt think youre logged in
      session[:loggedIn] = false
      session[:errorMessage] = "Login"
      session[:errorLink]  =  "/"
      attempts +=1
      if attempts >= 10
        p "too many attempt"
        session[:errorMessage2] = "please wait 30"
        session[:tooMany] = true
      end
      redirect("/fail")
    end
      
}

# Logs out user
#
post("/logOut"){
  session[:loggedIn] = false
  session[:id] = nil
  session[:username] = nil 
  session[:password] = nil
  redirect("/")
}

# Used to signup
#
# @param [String] username
# @param [String] password
# @see Model#newUser
post("/signup"){
    username = params[:username]
    password = params[:password]
    password_redo = params[:password_redo]
    # checks for password redos
    if password == password_redo 
      # password = password + salt adds salt
      if newUser(username, password)
        newUser(username, password)
        session[:successMessage] = "sign up"
        redirect("/success")
      else
        session[:errorMessage] = "making a unique username"
        session[:errorLink]  =  "/"
        redirect("/fail")
      end
    else
      session[:errorMessage] = "matching the passwords"
      session[:errorLink]  =  "/"
      redirect("/fail")
    end
}

# user functions

# User startpage
#
# @see Model#checkPosts
get("/users/index"){
  # sends all the posts of a suer to a session cookie and redirect them to the profile page
  session[:postInfo] = checkPosts(session[:id])
  slim(:"users/index")
}

# Views another user
#
# @param [String] user
# @see Model#checkPosts
get("/show/:user"){
  user = params[:user]
  # ches for all the user info
  posts = checkPosts(getId(user))
  slim(:"users/show", :locals=>{ posts: posts, 
  user: user})
}

# posts

# Makes posts
#
# @param [String] title
# @param [String] content
# @see Model#makePost
post("/post/new"){
  name = params[:title]
  content = params[:content]
  user_id = session[:id]
  if name == "" 
    session[:errorMessage] = "naming"
    session[:errorLink] = "/users/index"
    redirect("/fail")
  end
  if content == ""
    session[:errorMessage] = "writing"
    session[:errorLink] = "/users/index"
    redirect("/fail")
  end
  makePost(name,content,user_id)
  redirect("users/index")
}

# Deletes posts
#
# @param [String] id
# @see Model#deletePost
post("/post/:id/delete"){
  id = params[:id]
  session[:successMessage] = "delete a post"
  deletePost(id)
  redirect("/success")
}

# Edits posts
#
# @param [String] id
# @see Model#checkPost
get("/post/:id/edit"){
  session[:postId] = params[:id]
  id = session[:postId]
  
  currentName = checkPost(id)[0]["name"]
  # Sets current name and content to add if empty boxes are left
  session[:currentName] = currentName
  currentContent = checkPost(id)[0]["content"]
  session[:currentContent] = currentContent
  slim(:"/posts/edit")
}

# Edits post in db
#
# @param [String] newTitle
# @param [String] newContent
# @see Model#updatePost
post("/post/update"){
  id = session[:postId]
  newName = params[:newTitle]
  newContent = params[:newContent]
  # Checks if new name or content is empty and adds an error message if true. Also reverts to current name and text etc etc
  if newName == "" 
    newName = session[:currentName]
    newContent = session[:currentContent]
    session[:errorMessage] = "naming"
    
    redirect("/fail")
  end
  if newContent == ""
    newName = session[:currentName]
    newContent = session[:currentContent]
    session[:errorMessage] = "writing"
    
    redirect("/fail")
  end
    updatePost(id, newName, newContent)
    redirect(session[:redirectLink])
}

# Homepage for viewing posts
#
# @see Model#allPosts
get("/posts/index"){
  session[:allPosts] = allPosts()
  slim(:"posts/index")
}

# Likes post
#
# @param [String] id
# @see Model#likePost
post("/post/:id/like"){
  postId = params[:id]
  userId = session[:id]
  likePost(userId, postId)
  redirect(session[:redirectLink])
}

# Unlikes post
#
# @param [String] id
# @see Model#unlikePost
post("/post/:id/unlike"){
  postId = params[:id]
  userId = session[:id]
  unlikePost(userId, postId)
  redirect(session[:redirectLink])
}
