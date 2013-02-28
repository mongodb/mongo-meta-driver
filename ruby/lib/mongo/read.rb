module Mongo
  class Read

    # Operation is Protocol::Query, Protocol::GetMore, etc.
    def initialize(operation)
    end

    # The Cursor or Query will tell us the node to execute on.
    def execute(node)
    end
  end
end
