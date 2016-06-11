require 'logger'
require 'image_optim'

class SiteTasks
  attr_reader :logger

  def initialize
    @logger = Logger.new(STDOUT) 
  end

  def compress_images
    logger.info("#{' ' * 6}Compressing images...")
    image_optim = ImageOptim.new(pngout: false, svgo: false)
    Dir["source/**/*.{png,jpeg,jpg}"].each do |img|
      logger.info("#{' ' * 8}compressing #{img}")
      image_optim.optimize_image!(img)
    end
  end
end

task :load_tasks do
  @doer = SiteTasks.new
end

desc "Compresses all source images using image_optim"
task :compress => :load_tasks do
  @doer.compress_images
end
