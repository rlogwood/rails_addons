  has_many :posts

  def admin?
    role == 'admin'
  end

  def regular?
    role == 'regular'
  end

  def guest?
    role == 'guest'
  end
