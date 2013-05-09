require 'sprite_factory'

SpriteFactory.run!('img/sprite', :library => 'chunkypng', :nocomments => true, :output_image => 'img/sprite.png', :output_style => 'css/sprite.css' ) do |images|
  images.map do |image_name, metadata|
    '.sprite-' + image_name.to_s + '{ background-position: ' + (-1 * metadata[:cssx]).to_s + 'px ' + (-1 * metadata[:cssy]).to_s + 'px' + '; }'
  end.join("\n")
end
