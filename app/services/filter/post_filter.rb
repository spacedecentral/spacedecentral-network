module Filter
  class PostFilter
    attr_reader :posts

    CATEGORIES = [
      TRENDING = 'trending',
      RECENT   = 'recent'
    ]

    def self.call(*args)
      new(*args).call
    end

    def initialize(params, page = 1, per = 10)
      @params     = params
      @page       = page
      @per_page   = per
      @conditions = {}
    end

    def self.call(*args)
      new(*args).call
    end

    def call
      joins_str = "LEFT JOIN replies ON replies.replicable_type = 'Post' AND replies.replicable_id = posts.id"
      where_clause = ''

      if @params[:mission_ids].present?
        where_clause = "postable_type = 'Mission' AND postable_id IN (#{@params[:mission_ids].join(',')})"
      end

      if @params[:tag_ids].present?
        joins_str << " INNER JOIN tag_references ON tag_references.post_id = posts.id INNER JOIN tags ON tags.id = tag_references.tag_id"
        where_clause << " AND tags.id IN (#{@params[:tag_ids].join(',')})"
      end

      if @params[:keyword].present?
        keyword = @params[:keyword].to_s.strip

        where_clause << " AND posts.title LIKE '%#{keyword}%' OR posts.content LIKE '%#{keyword}%'"
      end

      if @params[:category].to_s == TRENDING
        order_clause = "replies_count desc, posts.created_at desc, MAX(replies.updated_at) desc"
      else
        order_clause = "posts.pinned desc, posts.created_at desc, MAX(replies.updated_at) desc"
      end

      puts where_clause
      where_clause = where_clause.strip.gsub(/\AAND|AND\z/, '')

      @posts = Post.joins(joins_str)
        .where(where_clause)
        .group('posts.id')
        .order(order_clause)
        .page(@page).per(@per_page)
    end
  end
end
