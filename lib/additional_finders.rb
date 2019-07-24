module AdditionalFinders
  def find_by_prefix(prefix)
    find(prefix.match(/\d+/)[0])
  rescue
    find(prefix)
  end
end