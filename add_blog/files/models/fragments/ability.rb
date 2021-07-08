
    user ||= User.new(role: "guest")
    # NOTE: if user.persisted? # implies a real user if saved in the database

    if user.admin?
      can :manage, Post
    elsif user.regular?  # TBD
      can :manage, Post, user_id: user.id # scope needs to be for what they own
    end

    can :read, Post # everyone should be able to read posts

