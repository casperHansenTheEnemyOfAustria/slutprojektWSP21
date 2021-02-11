require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'rails'
enable :sessions
def mk_db()
    db = SQLite3::Database.new("db/skolan.db")
    return db
end

def loginfunc(username, password)
    db = mk_db()
    db.results_as_hash = true
    usernames = db.execute("SELECT name FROM users ")
    
    
    if usernames.include?({"name" => username}) == true
        info = db.execute("SELECT * FROM users where name = ?", username).first
        password_digest = info["pwdigest"]
        if BCrypt::Password.new(password_digest) == password
            return true
        else
            return false
        end
    else 
            return false
    end
end

def admin(username)
    db = mk_db()
    db.results_as_hash = true
    info = db.execute("SELECT * FROM users where name = ?", username).first
    if info["admin?"] == "1"
        return true
    else
        return false
    end   
        
end

def get_id(username)
    db = mk_db()
    db.results_as_hash = true
    info = db.execute("SELECT * FROM users where name = ?", username).first
    id = info["id"]
    return id
end

def new_user(username, password)
    admins = ["1"]
    password_digest = BCrypt::Password.create(password)
    db = mk_db()
    db.results_as_hash = true
    db.execute("INSERT INTO users (name, pwdigest) VALUES (?, ?)", username, password_digest)
    # if admins.include?(username)
    #     db.execute("INSERT INTO users (admin?) VALUES ('1')")
    # else
    #     db.execute("INSERT INTO users (admin?) VALUES ('0')")
    # end
end
