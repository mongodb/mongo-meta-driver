# look up the Ruby classes corresponding to operation names
OPNAME_TO_CLASS =
{
  "OP_UPDATE"       => Mongo::Wire::RequestMessage::Update,
  "OP_INSERT"       => Mongo::Wire::RequestMessage::Insert,
  "OP_QUERY"        => Mongo::Wire::RequestMessage::Query,
  "OP_GET_MORE"     => Mongo::Wire::RequestMessage::GetMore,
  "OP_DELETE"       => Mongo::Wire::RequestMessage::Delete,
  "OP_KILL_CURSORS" => Mongo::Wire::RequestMessage::KillCursors
}

Transform /^generating an? (\S+) message$/ do |opname|
  OPNAME_TO_CLASS.fetch(opname)
end

Transform /^the document (.*)$/ do |doc_str|
  if doc_str.strip.empty?
    nil
  else
    JSON[doc_str]
  end
end

# produce an array of documents
Transform /^table:document$/ do |table|
  docs = table.rows.map do |doc_str_singleton|
    doc_str = doc_str_singleton.first
    if doc_str.strip.empty?
      nil
    else
      JSON[doc_str]
    end
  end
end

Transform /^I am (not | |).+$/ do |empty_or_not|
  empty_or_not.strip.empty?
end

Transform /^ is (not | |)$/ do |empty_or_not|
  empty_or_not.strip.empty?
end