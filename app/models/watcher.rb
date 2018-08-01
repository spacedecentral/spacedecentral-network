class Watcher < ApplicationRecord
  belongs_to :user
  belongs_to :watchable, polymorphic: true, counter_cache: false

  def toggle
    self.destroy if self.persisted?

    self.save
  end

end
