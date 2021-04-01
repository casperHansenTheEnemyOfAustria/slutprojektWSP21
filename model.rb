require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'rails'
enable :sessions

grabs database
def mkDb()
    db = SQLite3::Database.new("db/skolan.db")
    return db
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


# post related functions
# checks for all posts on entire site
def allPosts()
    db = mkDb()
    db.results_as_hash = true 
    return db.execute("SELECT * FROM POSTS")
end

# checks all posts of one user
def checkPosts(id)
    db = mkDb()
    db.results_as_hash = true
    postsInfo = db.execute("SELECT * FROM posts WHERE owner_id = ?", id)
    return postsInfo 
end

# checks infor for a single post
def checkPost(id)
    db = mkDb()
    db.results_as_hash = true
    postInfo = db.execute("SELECT * FROM posts WHERE id = ?", id)
    p postInfo
    return postInfo
end

# makes post
def makePost(name, content, user_id)
    db = mkDb()
    db.results_as_hash = true
    db.execute("INSERT INTO posts (name, content, owner_id) VALUES (?, ?, ?)", name,content, user_id).first
end

# deletes post
def deletePost(id)
    db = mkDb()
    db.results_as_hash = true
    db.execute("DELETE FROM posts WHERE id = ?", id)
end

# updates post
def updatePost(id, title, text)
    db = mkDb()
    db.results_as_hash = true
    db.execute("UPDATE posts SET name = ?, content = ? WHERE id = ?", title, text, id)
end

# add a like to a post
def likePost(userId, postId)
    db = mkDb()
    db.results_as_hash = true
    p "#{userId} likes #{postId}"
    db.execute("INSERT INTO likes (user_id, post_id) VALUES (?, ?)", userId, postId).first
end

# removes like from post
def unlikePost(userId, postId)
    db = mkDb()
    db.results_as_hash = true
    db.execute("DELETE FROM likes WHERE post_id = ? AND user_id = ? ", postId, userId).first
end

# finds all posts liked by a user
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

# todo: add number of likes finder from db using like counter
def numberOfLikes(postId) 
end