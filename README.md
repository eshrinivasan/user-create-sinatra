# anonymous-app

- bundle install
- rake db:migrate
- bundle exec rackup


Other info:

- rake db:create_migration NAME=create_users
- Creates the rb file under db/migrate/xxx_create_users.rb
- Edit this file to add fields for the table and give the table a name
- To create the table, use rake db:migrate
- bundle exec rackup
