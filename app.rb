
require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'rails'
require 'byebug'
require_relative("./model.rb")
enable :sessions

salt = "awoogamonke"

# login functions


# homepage
get("/"){
    if session[:loggedIn] == nil
      session[:loggedIn] = false
    end
    session[:ipAdress] = request.ip
    # logs peoples ip adress for saving usernames
    print "this is your ip adress #{request.ip}"
    slim(:index)
}

# used to show different sucessmessages depeding on what happened
get("/success"){
  slim(:success)
}

# used to show various fail messages depeding on the situation
get("/fail"){
  slim(:fail )
} 

# used to log in
post("/login"){
    username = params[:username]
    password = params[:password] + salt

      if loginfunc(username, password)
        # sets the session username to the correct ones for further use
        session[:username] = username
        # finds the id
        session[:id] = getId(username)
        # makes sure the site knows youre logged in
        session[:loggedIn] = true

        # checks for admin priviliges
        if admin(username)
          session[:admin] = true
        end
        # gets all the user posts and their info
        session[:postInfo] = checkPosts(session[:id])
        redirect("users/index")
        
      else
        # makes sure it doesnt think youre logged in
        session[:loggedIn] = false
        session[:errorMessage] = "Login"
        session[:errorLink]  =  "/"
        redirect("/fail")
      end
}

# logs out user
post("/logOut"){
  session[:loggedIn] = false
  session[:id] = nil
  session[:username] = nil 
  session[:password] = nil
  redirect("/")
}

used to signup
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

get("/users/index"){
  # sends all the posts of a suer to a session cookie and redirect them to the profile page
  session[:postInfo] = checkPosts(session[:id])
  slim(:"users/index")
}

# for when you want to view another user
get("/show/:user"){
  user = params[:user]
  # ches for all the user info
  posts = checkPosts(getId(user))
  slim(:"users/show", :locals=>{ posts: posts, 
  user: user})
}

# posts

# makes posts
post("/makePost"){
  name = params[:title]
  content = params[:content]
  user_id = session[:id]
  makePost(name,content,user_id)
  p "look at this #{session[:postInfo]}"
  redirect("users/index")
}

# deletes posts
post("/deletePost/:id"){
  id = params[:id]
  session[:successMessage] = "delete a post"
  deletePost(id)
  redirect("/success")
}

# edits posts
get("/editPost/:id"){
  session[:postId] = params[:id]
  id = session[:postId]
  currentName = checkPost(id)[0]["name"]
  # sets current name and content to add if empty boxes are left
  session[:currentName] = currentName
  currentContent = checkPost(id)[0]["content"]
  session[:currentContent] = currentContent
  slim(:"/posts/edit")
}

# for the post form
post("/editPost"){
  id = session[:post_id]
  newName = params[:newTitle]
  newContent = params[:newContent]
  
  p newName
  p newContent
  # checks if new name or content is empty and adds an error message if true. Also reverts to current name and text etc etc
  if newName == "" 
    newName = session[:currentName]
    newContent = session[:currentContent]
    session[:errorMessage] = "naming"
    session[:errorLink] = "/users/index"
    redirect("/fail")
  end
  if newContent == ""
    newName = session[:currentName]
    newContent = session[:currentContent]
    session[:errorMessage] = "writing"
    session[:errorLink] = "/users/index"
    redirect("/fail")
  end
    updatePost(id, newName, newContent)
    redirect("users/index")
}

# for the posts page where all user posts are shown
get("/posts/index"){
  session[:allPosts] = allPosts()
  slim(:"posts/index")
}

# likes post
post("/likePost/:id"){
  p "swag"
  postId = params[:id]
  userId = session[:id]
  likePost(userId, postId)
  redirect(session[:redirectLink])
}

# unlikes post
post("/unlikePost/:id"){
  p "swag"
  postId = params[:id]
  userId = session[:id]
  unlikePost(userId, postId)
  redirect(session[:redirectLink])
}
