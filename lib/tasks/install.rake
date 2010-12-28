require 'active_record'
require 'active_record/fixtures'

desc "Install Insoshi"
task :install => :environment do |t|
  Rake::Task["db:migrate"].invoke
  using_email = !!(ENV['DOMAIN'] && ENV['SMTP_SERVER']) # explicit true
  pref = Preference.create!(:app_name => ENV['APP_NAME'], :domain => ENV['DOMAIN'] || '', :server_name => ENV['SERVER_NAME'], :smtp_server => ENV['SMTP_SERVER'] || '', :email_notifications => using_email) 
  p = Person.new(:name => "admin", :email => "admin@example.com", :password => "admin", :password_confirmation => "admin", :accept_agreement => true, :description => "")
  p.save!
  p.admin = true
  p.save
  account = Account.new(:name => 'personal', :balance => 0, :person => p)
  account.save!
  address = Address.new(:name => 'personal', :person => p)
  address.save!

  group_attributes = {:name => ENV['APP_NAME'],
                      :description => "The system installation created this group with a currency and configured it as a mandatory group. All people who register on the system will automatically join all mandatory groups. By default, there is no credit limit configured for new account holders for this group although you may configure one.",
                      :mode => Group::PUBLIC,
                      :unit => 'hours',
                      :asset => 'hours',
                      :owner => p,
                      :adhoc_currency => true
  }

  g = Group.create!(group_attributes)
  # mandatory is attr protected
  g.mandatory = true
  g.save
  pref.default_group_id = g.id
  pref.save!

  p.default_group_id = g.id
  p.save!
end
