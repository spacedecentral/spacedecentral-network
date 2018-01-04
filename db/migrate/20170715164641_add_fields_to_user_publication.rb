class AddFieldsToUserPublication < ActiveRecord::Migration[5.0]
  def change
    add_column :user_publications, :publisher, :string
    add_column :user_publications, :abstract, :text
    add_column :user_publications, :doi, :string
    add_column :user_publications, :publication_date, :datetime
    add_column :user_publications, :publication_url, :string
    add_column :user_publications, :volume, :string
    add_column :user_publications, :issue, :string
    add_column :user_publications, :arXiv, :string
    add_column :user_publications, :PMID, :integer
    add_column :user_publications, :keep_private, :boolean
  end
end
