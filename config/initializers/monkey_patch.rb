class NilClass
  def to_b
    false
  end
end

class String
  def to_b
    !! (self =~ /\A(t|true|yes|1)\z/i)
  end
end

class Integer
  def to_b
    ! (self == 0)
  end
end
