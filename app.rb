
require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'rails'
require_relative("./model.rb")
enable :sessions

salt = "awoogamonke"




get("/"){
    session[:ipAdress] = request.ip
    # logs peoples ip adress for saving usernames
    print "this is your ip adress #{request.ip}"
    slim(:loginScreen)
}

get("/sucess"){
  slim(:sucess)
}

get("/fail"){
  slim(:fail )
} 

get("/users/profile_page"){
  slim(:"users/profile_page")
}

post("/login"){
    username = params[:username]
    password = params[:password] + salt


      if loginfunc(username, password)
        session[:username] = username
        session[:id] = get_id(username)
        session[:loggedIn] = true
        if admin(username)
          session[:admin] = true
        end
        redirect("users/profile_page")
        
      else
        session[:loggedIn] = false
        redirect("/fail")
      end
}

post("/signup"){
    username = params[:username]
    password = params[:password]
    password_redo = params[:password_redo]
    if password == password_redo 
      password = password + salt
      new_user(username, password)
      redirect("/sucess")
    else
      print "passwords didnt match"
    end
}