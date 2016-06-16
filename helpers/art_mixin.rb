module ArtMixin
  def art_route(category, name)
    local = name.gsub(/^[0-9]+-?/,'').parameterize
    cat = category.parameterize
    "/#{config.images_dir}/art/#{cat}/#{local}.html"
  end
end
