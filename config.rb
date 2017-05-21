require_relative 'helpers/art_mixin'
include ArtMixin

###
# Page options, layouts, aliases and proxies
###
page "/index.html", :layout => "standard"
page "/colophon.html", :layout => "standard"
page "/blog/index.html", :layout => "standard"
page "/blog/page*/index.html", :layout => "standard"
page "/art/*", :layout => "art"

# Per-page layout changes:
#
# With no layout
page '/*.xml', layout: false
page '/*.json', layout: false
page '/*.txt', layout: false

# With alternative layout
# page "/path/to/file.html", layout: :otherlayout

# Proxy pages (http://middlemanapp.com/basics/dynamic-pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", locals: {
#  which_fake_page: "Rendering a fake page with a local variable" }
data.images.each do |category|
  category.works.each do |img|
    path = art_route(category.title, img.title)
    proxy path, "/art/index.html", locals: {focus_img: img}
  end
end

activate :sprockets
sprockets.append_path File.join(root, 'node_modules')

##
# Blog

activate :blog do |blog|
  blog.prefix = "blog"
  blog.layout = "blog_post"
  blog.permalink = "{year}/{month}/{day}/{title}.html"
  blog.paginate = true
  blog.page_link = "p{num}"
  blog.per_page = 7
end

##
# Ignores

ignore 'stylesheets/components/*'

# General configuration

set :summary_length, 500

activate :syntax
set :markdown_engine, :kramdown
set :markdown, fenced_code_blocks: true, smartypants: true

# Build-specific configuration
configure :build do
  activate :gzip do |gzip|
    gzip.exts = %w(.css .htm .html .js .svg .xhtml .json .png .jpeg)
  end

  # Minify CSS on build
  activate :minify_css

  # Minify Javascript on build
  activate :minify_javascript

  # Minify HTML on build
  activate :minify_html
end
