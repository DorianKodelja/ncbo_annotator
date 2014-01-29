source 'https://rubygems.org'

gem 'rake', '~> 10.0'
gem 'redis', '~> 3.0'
gem 'minitest', '~> 4.0'
gem 'cube-ruby', require: "cube"

# Development
gem 'pry', group: :development

# NCBO gems (can be from a local dev path or from rubygems/git)
ncbo_branch = ENV["NCBO_BRANCH"] || `git rev-parse --abbrev-ref HEAD`.strip || "staging"
gem 'goo', github: 'ncbo/goo', branch: ncbo_branch
gem 'sparql-client', github: 'ncbo/sparql-client', branch: ncbo_branch
gem 'ontologies_linked_data', github: 'ncbo/ontologies_linked_data', branch: "mallet_recognizer"
