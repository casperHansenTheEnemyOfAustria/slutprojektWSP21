
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
    session[:ipAdress] = request.ip
    # logs peoples ip adress for saving usernames
    print "this is your ip adress #{request.ip}"
    slim(:loginScreen)
}

get("/sucess"){
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
        redirect("users/profilePage")
        
      else
        session[:loggedIn] = false
        redirect("/fail")
      end
}

post("/logOut"){
  session[:loggediIn] = false
  session[:id] = nil
  redirect("/")
}

post("/signup"){
    username = params[:username]
    password = params[:password]
    password_redo = params[:password_redo]
    if password == password_redo 
      password = password + salt
      newUser(username, password)
      redirect("/sucess")
    else
      print "passwords didnt match"
    end
}

# user functions

get("/users/profilePage"){
  session[:postInfo] = checkPosts(session[:id])
  slim(:"users/profilePage")
}

post("/makePost"){
  name = params[:title]
  content = params[:content]
  user_id = session[:id]
  makePost(name,content,user_id)
  p "look at this #{session[:postInfo]}"
  redirect("users/profilePage")
}

post("/deletePost/:id"){
  id = params[:id]
  deletePost(id)
  redirect("users/profilePage")
}

get("/editPost/:id"){
  session[:post_id] = params[:id]

  slim(:"/users/editPost")
}

post("/editPost"){
  id = session[:post_id]
  newName = params[:newTitle]
  newContent = params[:newContent]
  currentName = checkPost(id)[0]["name"]
  currentContent = checkPost(id)[0]["content"]
  p newName
  p newContent
  if newName == "" 
    newName = currentName
  end
  if newContent == ""
    newContent = currentContent
  end
    updatePost(id, newName, newContent)
    redirect("users/profilePage")
}


# posts

get("/postboard"){
  session[:allPosts] = allPosts()
  slim(:"posts/postboard")
}
