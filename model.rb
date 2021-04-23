require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'rails'
enable :sessions


module Model
    # Grabs database info
    #
    # @return [Database] the entire db as a global var
    def mkDb()
        $db = SQLite3::Database.new("db/skolan.db")
        $db.results_as_hash = true
        return $db
    end
    # Finds username from id
    #
    # @param [String] the id
    #
    # @return [String] Username
    def usernameFinder(id)
        return $db.execute("SELECT name FROM users WHERE id = ?", id)[0][0]
    end

    # Compares credentials
    #
    # @param [String] username
    # @param [String] password
    #
    # @return [Boolean] if they match or not
    def loginFunc(username, password)
        username = username.to_s    
        usernames = $db.execute("SELECT name FROM users ")
        if usernames.include?({"name" => username}) == true
            info = $db.execute("SELECT * FROM users where name = ?", username).first
            password_digest = info["pwdigest"]
            if BCrypt::Password.new(password_digest) == password
                return true
            else
                return false
            end
        end
    end

    # Checks if admin
    #
    # @param [String] username
    #
    # @return [Boolean] if it is or not
    def admin(username)
        info = $db.execute("SELECT * FROM users where name = ?", username).first
        if info["admin?"] = 1
            return true
        else
            return false
        end   
            
    end

    # Gets id from username
    #
    # @param [String] username
    #
    # @return [String] id
    def getId(username)
        info = $db.execute("SELECT * FROM users WHERE name = ?", username).first
        id = info["id"]
        return id
    end

    # Makes new user in db
    # 
    # @param [String] username
    # @param [String] password
    #
    # @return [Boolean]
    def newUser(username, password)
        usernames = $db.execute("SELECT name FROM users ")
        if !usernames.include?({"name" => username}) 
            password_digest = BCrypt::Password.create(password)
            $db.execute("INSERT INTO users (name, pwdigest) VALUES (?, ?)", username, password_digest).first
           return true
        else
            return false
        end
    end


    # post related functions

    # Checks for all posts on entire site
    #
    # 
    # @return [Hash] all posts
    def allPosts()
        
        return $db.execute("SELECT * FROM POSTS")
    end

    # Checks all posts of one user
    #
    # @param [String] id
    #
    # @return [Hash] all posts
    def checkPosts(id)
        postsInfo = $db.execute("SELECT * FROM posts WHERE owner_id = ?", id)
        return postsInfo 
    end

    # Checks info for a single post
    #
    # @param [String] id
    #
    # @return [Hash] all posts
    def checkPost(id)
        postInfo = $db.execute("SELECT * FROM posts WHERE id = ?", id)
        p postInfo
        return postInfo
    end

    # Makes post
    #
    # @param [String] username
    # @param [String] content
    # @param [String] userId
    #
    def makePost(name, content, user_id)
        $db.execute("INSERT INTO posts (name, content, owner_id) VALUES (?, ?, ?)", name,content, user_id).first
    end

    # Deletes post
    #
    # @param [String] id
    #
    def deletePost(id)
        $db.execute("DELETE FROM posts WHERE id = ?", id)
    end

    # Updates post
    #
    # @param [String] id
    # @param [String] title
    # @param [String] text
    #
    def updatePost(id, title, text)
        $db.execute("UPDATE posts SET name = ?, content = ? WHERE id = ?", title, text, id)
    end

    # Add a like to a post'
    #
    # @param [String] userId 
    # @param [String] postId
    def likePost(userId, postId)
        # db = mkDb()
        p "#{userId} likes #{postId}"
        $db.execute("INSERT INTO likes (user_id, post_id) VALUES (?, ?)", userId, postId).first
    end

    # Removes like from post
    #
    # @param [String] userId 
    # @param [String] postId
    #
    def unlikePost(userId, postId)
        $db.execute("DELETE FROM likes WHERE post_id = ? AND user_id = ? ", postId, userId).first
    end

    # Finds all posts liked by a user
    #
    # @param [String] userId 
    # @param [String] postId
    #
    # @return [Boolean]
    def findLikes(userId, postId)
        # had to do this for non hash exeption
        db  = SQLite3::Database.new("db/skolan.db")
        db.results_as_hash = false
        postId = postId.to_i
        
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

end