require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'rails'
enable :sessions
def mkDb()
    db = SQLite3::Database.new("db/skolan.db")
    return db
end

def allPosts()
    db = mkDb()
    db.results_as_hash = true 
    return db.execute("SELECT * FROM POSTS")
end

def usernameFinder(id)
    db = mkDb() 
    return db.execute("SELECT name FROM users WHERE id = ?", id)[0][0]
end

def loginfunc(username, password)
    db = mkDb()
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
    db = mkDb()
    db.results_as_hash = true
    info = db.execute("SELECT * FROM users where name = ?", username).first
    if info["admin?"] == "1"
        return true
    else
        return false
    end   
        
end

def getId(username)
    db = mkDb()
    db.results_as_hash = true
    info = db.execute("SELECT * FROM users WHERE name = ?", username).first
    id = info["id"]
    return id
end

def newUser(username, password)
    admins = ["1"]
    password_digest = BCrypt::Password.create(password)
    db = mkDb()
    db.results_as_hash = true
    db.execute("INSERT INTO users (name, pwdigest) VALUES (?, ?)", username, password_digest)
    # if admins.include?(username)
    #     db.execute("INSERT INTO users (admin?) VALUES ('1')")
    # else
    #     db.execute("INSERT INTO users (admin?) VALUES ('0')")
    # end
end

def checkPosts(id)
    db = mkDb()
    db.results_as_hash = true
    postsInfo = db.execute("SELECT * FROM posts WHERE owner_id = ?", id)
    return postsInfo 
end

def checkPost(id)
    db = mkDb()
    db.results_as_hash = true
    postInfo = db.execute("SELECT * FROM posts WHERE id = ?", id)
    p postInfo
    return postInfo
end



def makePost(name, content, user_id)
    db = mkDb()
    db.results_as_hash = true
    db.execute("INSERT INTO posts (name, content, owner_id) VALUES (?, ?, ?)", name,content, user_id).first
end

def deletePost(id)
    db = mkDb()
    db.results_as_hash = true
    db.execute("DELETE FROM posts WHERE id = ?", id)
end

def updatePost(id, title, text)
    db = mkDb()
    db.results_as_hash = true
    db.execute("UPDATE posts SET name = ?, content = ? WHERE id = ?", title, text, id)
end
