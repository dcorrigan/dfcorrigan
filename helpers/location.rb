module Location
  def active?(item, path)
    item == path || "/#{path}"[/#{item}/]
  end
end
