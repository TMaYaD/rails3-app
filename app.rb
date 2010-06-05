# We love RVM
# create rvmrc
rvmrc = <<-RVMRC
rvm_gemset_create_on_use_flag=1
rvm gemset use #{app_name}
RVMRC

create_file ".rvmrc", rvmrc

#empty_directory "lib/generators"
#git :clone => "--depth 0 http://github.com/TMaYaD/rails3-app.git lib/generators"
#remove_dir "lib/generators/.git"

# Rack-Environmental is a nice rack middleware to have
gem "rack-environmental"
middleware = <<-CONFIGRU
use Rack::Environmental,
  :staging =>     { :url => /^staging.+$/   },
  :test =>        { :url => /^test.+$/      },
  :development => { :url => /^localhost.+$/ }
CONFIGRU

prepend_file 'config.ru', middleware
# We love RSpec, factory_girl and haml
# Set up the gems and make them default generators
gem "haml"
gem "rails3-generators", :group => :development
gem "rspec-rails", ">= 2.0.0.beta.8", :group => :test
gem "factory_girl", :group => :test

generators = <<-GENERATORS

    config.generators do |g|
      g.template_engine :haml
      g.test_framework :rspec, :fixture => true, :helper_specs => false, :routing_specs => true
      g.fixture_replacement :factory_girl, :dir => "spec/factories"
      g.integration_tool :rspec
      g.helper :rspec
    end
GENERATORS

application generators

# We love jquery
# Include it instead of rails' own prototype
get "http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js",  "public/javascripts/jquery.js"
get "http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.1/jquery-ui.min.js", "public/javascripts/jquery-ui.js"
get "http://github.com/rails/jquery-ujs/raw/master/src/rails.js", "public/javascripts/rails.js"

jquery = <<-JQUERY
ActionView::Helpers::AssetTagHelper.register_javascript_expansion \
  :jquery => %w(jquery jquery-ui rails)
JQUERY

initializer "jquery.rb", jquery

# Prepare a layout for the app
# TODO: Customise the layout and index page
layout = <<-LAYOUT
!!!
%html
  %head
    %title #{app_name.humanize}
    = stylesheet_link_tag :all
    = javascript_include_tag :jquery
    = csrf_meta_tag
  %body
    = yield
LAYOUT

remove_file "app/views/layouts/application.html.erb"
create_file "app/views/layouts/application.html.haml", layout

# Prepare README, All the big boys do
remove_file "README"
prepend_file "doc/README_FOR_APP", "TODO: "
run "ln -s doc/README_FOR_APP README"

# Prepare the database
run "cp config/database.yml config/database.example.yml"
#rake "db:migrate"

# We love git
# prepare the files and stage the changes

gitignore = <<-GITIGNORE
*.swp
*~

config/database.yml
GITIGNORE

append_file ".gitignore", gitignore
create_file "log/.gitkeep"
create_file "tmp/.gitkeep"

git :init
git :add => "."

docs = <<-DOCS

#Run the following commands to complete the setup of #{app_name.humanize}:

cd #{app_name}
gem install bundler
bundle install
rails generate rspec:install

DOCS

log docs
