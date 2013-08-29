# Compiling the Gem
# gem build aqueduct-postgresql.gemspec
# gem install ./aqueduct-postgresql-x.x.x.gem --no-ri --no-rdoc --local
#
# gem push aqueduct-postgresql-x.x.x.gem
# gem list -r aqueduct-postgresql
# gem install aqueduct-postgresql

$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'aqueduct-postgresql/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'aqueduct-postgresql'
  s.version     = Aqueduct::Postgresql::VERSION::STRING
  s.authors     = ['Remo Mueller']
  s.email       = ['remosm@gmail.com']
  s.homepage    = 'https://github.com/remomueller'
  s.summary     = 'Connect to PostgreSQL through Aqueduct'
  s.description = 'Connects to PostgreSQL through Aqueduct interface'
  s.license     = 'CC BY-NC-SA 3.0'

  s.files = Dir['{app,config,db,lib}/**/*'] + ['aqueduct-postgresql.gemspec', 'CHANGELOG.md', 'LICENSE', 'Rakefile', 'README.md']
  s.test_files = Dir['test/**/*']

  s.add_dependency 'rails',     '~> 4.0.0'
  s.add_dependency 'aqueduct',  '~> 0.2.0'
  s.add_dependency 'pg',        '~> 0.16.0'

  s.add_development_dependency 'sqlite3'
end
