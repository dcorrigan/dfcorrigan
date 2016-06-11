module AssetLocation
  def art_image_for(num)
    res = sitemap.resources.find { |r| r.path[/#{config.images_dir}\/art\/0*#{num}-/] }
    res.url
  end

  def art_thumb_for(num)
    res = sitemap.resources.find { |r| r.path[/#{config.images_dir}\/art\/thumbs\/0*#{num}-/] }
    res.url
  end
end
