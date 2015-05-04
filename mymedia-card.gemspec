Gem::Specification.new do |s|
  s.name = 'mymedia-card'
  s.version = '0.1.0'
  s.summary = 'In the context of the MyMedia system it is used for publishing a media file using the Kvx XML format as the container.'
  s.authors = ['James Robertson']
  s.files = Dir['lib/**/*.rb']
  s.add_runtime_dependency('mymedia', '~> 0.2', '>=0.2.5')
  s.signing_key = '../privatekeys/mymedia-card.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@r0bertson.co.uk'
  s.homepage = 'https://github.com/jrobertson/mymedia-card'
end
