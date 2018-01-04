# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'
require "rake/testtask"

Rails.application.load_tasks


Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.warning = false
  t.test_files = FileList['test/**/*Test.rb']
end

# task :default => :test