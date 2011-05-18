#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require File.join(File.dirname(__FILE__), "..", "..", "config", "environment")
require File.join(File.dirname(__FILE__), "..", "..", "spec", "helper_methods")

def set_app_config username
  current_config = YAML.load(File.read(Rails.root.join('config', 'app.yml.example')))
  current_config[Rails.env.to_s] ||= {}
  current_config[Rails.env.to_s]['pod_url'] ||= "#{username}.joindiaspora.com"
  current_config['default']['pod_url'] ||= "#{username}.joindiaspora.com"
  file = File.new(Rails.root.join('config','app.yml'),'w')
  file.write(current_config.to_yaml)
  file.close
end

username = "tom"
set_app_config username unless File.exists?(Rails.root.join('config', 'app.yml'))

require Rails.root.join('config',  "initializers", "_load_app_config.rb")
include HelperMethods
module Resque
  def enqueue(klass, *args)
    if $process_queue
      klass.send(:perform, *args)
    else
      true
    end
  end
end
# Create seed user
user = User.build( :email => "tom@tom.joindiaspora.com",
                     :username => "tom",
                    :password => "evankorth",
                    :password_confirmation => "evankorth",
                    :person => {
                      :profile => { :first_name => "Alexander", :last_name => "Hamiltom",
                      :image_url => "/images/user/tom.jpg"}})

user.save!
user.person.save!
user.seed_aspects

user2 = User.build( :email => "korth@tom.joindiaspora.com",
                    :password => "evankorth",
                    :password_confirmation => "evankorth",
                     :username => "korth",
                    :person => {:profile => { :first_name => "Evan", :last_name => "Korth",
                      :image_url => "/images/user/korth.jpg"}})


user2.save!
user2.person.save!
user2.seed_aspects
# connecting users

connect_users(user, user.aspects.first, user2, user2.aspects.first)
