
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

get("/"){
    if session[:loggedIn] == nil
      session[:loggedIn] = false
    end
    session[:ipAdress] = request.ip
    # logs peoples ip adress for saving usernames
    print "this is your ip adress #{request.ip}"
    slim(:index)
}

get("/success"){
  slim(:success)
}

get("/fail"){
  slim(:fail )
} 



post("/login"){
    username = params[:username]
    password = params[:password] + salt

      if loginfunc(username, password)
        session[:username] = username
        session[:id] = getId(username)
        session[:loggedIn] = true
        if admin(username)
          session[:admin] = true
        end
        session[:postInfo] = checkPosts(session[:id])
        redirect("users/index")
        
      else
        session[:loggedIn] = false
        session[:errorMessage] = "Login"
        session[:errorLink]  =  "/"
        redirect("/fail")
      end
}

post("/logOut"){
  session[:loggedIn] = false
  session[:id] = nil
  session[:username] = nil 
  session[:password] = nil
  redirect("/")
}

post("/signup"){
    username = params[:username]
    password = params[:password]
    password_redo = params[:password_redo]
    if password == password_redo 
      password = password + salt
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
  session[:postInfo] = checkPosts(session[:id])
  slim(:"users/index")
}

post("/makePost"){
  name = params[:title]
  content = params[:content]
  user_id = session[:id]
  makePost(name,content,user_id)
  p "look at this #{session[:postInfo]}"
  redirect("users/index")
}

post("/deletePost/:id"){
  id = params[:id]
  session[:successMessage] = "delete a post"
  deletePost(id)
  redirect("/success")
}

get("/editPost/:id"){
  session[:postId] = params[:id]
  id = session[:postId]
  currentName = checkPost(id)[0]["name"]
  session[:currentName] = currentName
  currentContent = checkPost(id)[0]["content"]
  session[:currentContent] = currentContent
  slim(:"/posts/edit")
}

post("/editPost"){
  id = session[:post_id]
  newName = params[:newTitle]
  newContent = params[:newContent]
  
  p newName
  p newContent
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


# posts

get("/posts/index"){
  session[:allPosts] = allPosts()
  slim(:"posts/index")
}

post("/likePost/:id"){
  p "swag"
  postId = params[:id]
  userId = session[:id]
  likePost(userId, postId)
  redirect("/posts/index")
}

post("/unlikePost/:id"){
  p "swag"
  postId = params[:id]
  userId = session[:id]
  unlikePost(userId, postId)
  redirect("/posts/index")
}
