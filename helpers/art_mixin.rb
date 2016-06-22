require 'fastimage'

module ArtMixin
  def art_route(category, name)
    local = name.gsub(/^[0-9]+-?/,'').parameterize
    cat = category.parameterize
    "/#{config.images_dir}/art/#{cat}/#{local}.html"
  end

  def image_dims(path)
    full_path = File.join(app.source_dir.to_s, path)
    dims = FastImage.size(full_path)
    OpenStruct.new(width: dims[0], height: dims[1])
  end
end
