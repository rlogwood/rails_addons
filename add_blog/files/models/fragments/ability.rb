
    user ||= User.new(role: "guest")
    # NOTE: if user.persisted? # implies a real user if saved in the database

    if user.admin?
      can :manage, Post
    elsif user.regular?  # TBD
      # NOTE: For multi-user blog site, users would need to manage their own blogs
      #can :manage, Post, user_id: user.id # scope needs to be for what they own
    end

    # NOTE: For single user Blog, only one admin user will be able to create, read posts
    # If creating a multi-user blog, we may consider having posts index that resembles
    # a blog, in which case users would be able to read published posts from other users
    #can :read, Post # everyone should be able to read posts

