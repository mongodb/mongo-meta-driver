module Mongo
  class Cursor
    include Enumerable

    attr_reader :node

    def each
    end

    def initialize(cluster, query, read_preference)
      @node = read_preference.select(cluster)
    end

    def initial_query
      Read.new(query).execute(node)
    end

    def get_more
      Read.new(query.get_more(cursor_id)).execute(node)
    end
  end
end
