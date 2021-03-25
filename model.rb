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
    db = mkDb()
    db.results_as_hash = true
    usernames = db.execute("SELECT name FROM users ")
    
    
    if !usernames.include?({"name" => username}) 
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
        return true
    else
        return false
    end
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

def likePost(userId, postId)
    db = mkDb()
    db.results_as_hash = true
    p "#{userId} likes #{postId}"
    db.execute("INSERT INTO likes (user_id, post_id) VALUES (?, ?)", userId, postId).first
end

def unlikePost(userId, postId)
    db = mkDb()
    db.results_as_hash = true
    db.execute("DELETE FROM likes WHERE post_id = ? AND user_id = ? ", postId, userId).first
end

def findLikes(userId, postId)
    postId = postId.to_i
    db = mkDb()
    
     allLikes = db.execute("SELECT post_id FROM likes WHERE user_id = ?", userId)
    
    if allLikes != nil
        p "all likes are #{allLikes}"
        p allLikes.include?([postId])
        if allLikes.include?([postId])
            p "this is true"
            return true
        else 
            return false
        end
    else
        return false
    end
end