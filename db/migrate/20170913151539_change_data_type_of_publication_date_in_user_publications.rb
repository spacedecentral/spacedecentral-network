class ChangeDataTypeOfPublicationDateInUserPublications < ActiveRecord::Migration[5.0]
  def change
    change_column :user_publications, :publication_date, :date
  end
end
