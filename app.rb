
require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'rails'
enable :sessions



def new_user(username, password)
    password_digest = BCrypt::Password.create(password)
    db = SQLite3::Database.new("db/skolan.db")
    db.execute("INSERT INTO users (name, pwdigest) VALUES (?, ?)", username, password_digest)
end

get("/"){

    session[:ipAdress] = request.ip
    # logs peoples ip adress for saving usernames
    print "this is your ip adress #{request.ip}"
    slim(:loginScreen)

}

post("/login"){
    username = params[:username]
    password = params[:password]
  
    db = SQLite3::Database.new("db/skolan.db")
    db.results_as_hash = true
    usernames = db.execute("SELECT name FROM users ")
    p usernames
    if usernames.include?({"name" => username}) == true
      info = db.execute("SELECT * FROM users where name = ?", username).first
      id = info["id"]
      password_digest = info["pwdigest"]
      if BCrypt::Password.new(password_digest) == password
        session[:username] = username
        session[:id] = id
        session[:loggedIn] = true
        redirect("users/profilePage")
        
      else
        session[:loggedIn] = false
        redirect("/fail")
      end
    else
      # for if the username doesnt exist
      redirect("/fail")
    end
}

post("/signup"){
    username = params[:username]
    password = params[:password]
    password_redo = params[:password_redo]
    db = SQLite3::Database.new("db/skolan.db")
    db.results_as_hash = true
    
    if password == password_redo 
      new_user(username, password)
    else
      print "passwords didnt match"
    end
}