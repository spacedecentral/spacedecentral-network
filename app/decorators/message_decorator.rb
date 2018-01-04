class MessageDecorator < ApplicationDecorator
  delegate_all

  def recepients_chip_data(recepients_ids)
    if recepients_ids.is_a?(String)
      recepients_ids = recepients_ids.split(',').map(&:to_i)
    end

    @recepients ||= User.where(id: recepients_ids).map do |user|
      {
        id: user.id,
        label: user.name,
        avatar: user.avatar.url(:thumb)
      }
    end.to_json
  end


  def chat_recepients_chip_data(recepients_ids)
    if recepients_ids.is_a?(String)
      recepients_ids = recepients_ids.split(',').map(&:to_i)
    end

    @recepients ||= User.where(id: recepients_ids).map do |user|
      {
        id: user.id,
        label: (user.name.nil? ? "" : user.name.split(' ').map{|i| i[0] }.join('')),
        avatar: user.avatar.url(:thumb)
      }
    end.to_json
  end
end
