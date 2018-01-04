module SubscriberTracker

  def self.set_online(room)
    $redis.set(room, 1)
  end

  def self.set_offline(room)
    $redis.set(room, 0)
  end

  def self.is_online(room)
    $redis.get(room).to_i == 1
  end

  def self.add_sub(room)
    count = sub_count(room)
    $redis.set(room, count + 1)
  end

  def self.remove_sub(room)
    count = sub_count(room)
    if count == 1
      $redis.del(room)
    else
      $redis.set(room, count - 1)
    end
  end

  def self.sub_count(room)
    $redis.get(room).to_i
  end
end