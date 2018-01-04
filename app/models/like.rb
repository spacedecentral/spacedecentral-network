class Like < ApplicationRecord
  belongs_to :user
  belongs_to :likable, polymorphic: true, counter_cache: true

  def toggle
    self.destroy if self.persisted?

    self.save
  end
end
