require 'bundler/capistrano'

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

set :rack_env, "production"
set :domain, '198.211.110.136'
set :application, 're51'
set :repository,  'https://github.com/marbemac/re51.git'
set :branch,  'master'
set :deploy_to, "/var/www/#{application}"

set :scm, :git
set :scm_verbose, true

# roles (servers)
role :web, domain
role :app, domain
role :db,  domain, :primary => true

set :deploy_via, :remote_cache
set :use_sudo, false
set :keep_releases, 3
set :user, 'root'

set :bundle_without, [:development, :test]

set :rake, "#{rake} --trace"

set :default_environment, {
    'PATH' => "usr/local/rvm/gems/ruby-1.9.3-p392@re51/bin:/usr/local/rvm/gems/ruby-1.9.3-p392@global/bin:/usr/local/rvm/rubies/ruby-1.9.3-p392/bin:/usr/local/rvm/bin:/root/.rbenv/shims:/root/.rbenv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games",
    'RUBY_VERSION' => 'ruby 1.9.3',
    'GEM_HOME'     => '/usr/local/rvm/gems/ruby-1.9.3-p392@re51',
    'GEM_PATH'     => '/usr/local/rvm/gems/ruby-1.9.3-p392@re51:/usr/local/rvm/gems/ruby-1.9.3-p392@global',
    'BUNDLE_PATH'  => '/usr/local/rvm/gems/ruby-1.9.3-p392@re51'  # If you are using bundler.
}

after 'deploy:setup' do
  sudo "chown -R #{user} #{deploy_to} && chmod -R g+s #{deploy_to}"
end

namespace :deploy do
  desc "Restart Passenger"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end


# deal with caching
after "deploy:setup", "create_page_cache"
desc "Creates the cache dir"
task :create_page_cache, :roles => :app do
  run "umask 02 && mkdir -p #{shared_path}/cache"
end

after "deploy:update_code","symlink_shared_dirs"
desc "Links the public/cache with the shared/cache"
task :symlink_shared_dirs, :roles => :app do
  run "cd #{release_path} && ln -nfs #{shared_path}/cache #{release_path}/public/cache"
end

set :flush_cache, true

task :keep_page_cache do
  set :flush_cache, false
end

after "deploy:cleanup", "flush_page_cache"
desc "Empties the page cache"
task :flush_page_cache, :roles => :app do
  if flush_cache
    run "rm -rf #{shared_path}/cache/*"
  end
end