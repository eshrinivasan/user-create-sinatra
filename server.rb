require "sinatra"
require "sinatra/cookies"
require "active_record"
require "sqlite3"
require 'pry'
require 'pry-byebug'
require 'securerandom'
require 'json'
require 'spreadsheet'

require_relative 'models/user_model'
require_relative 'models/todo_model'

# The "ActiveRecord" object has a "Base" class which in turn has a
# "establish_connection" method which below creates a
# "sqlite3" database connection and will eventually
# create a database named "userdb.sqlite3" in the root directory
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => "userdb.sqlite3")


# "App" class inherits from "ActiveRecord::Base"
class App < Sinatra::Base
      configure do
          set :sessions, true
          set :session_secret, '\x1b\x7fJ\x833\xac~\xe6\xbb\xba\nf'
      end
      
      @count = 0

      def self.increment()
        @count = @count + 1
      end

       def self.count()
        return @count
      end

      before do   # Before every request, make sure they get assigned an ID.
          session[:id] ||= SecureRandom.hex(3)
          @unique_id = session[:id]
      end

      get "/" do
        redirect "/hukka"
      end

      get "/:team" do
        response.set_cookie 'user-id',
         {:value=> session[:id], :max_age => "1210000", :httponly => true }
         #@todos = Todo.all.order(points: :desc)
         @todos = Todo.where('user_name = ? and team = ?', @unique_id, params[:team].to_s).order(points: :desc)
         haml :index
      end

      get "/:team/all" do
         @todos = Todo.where('team = ?', params[:team].to_s).order(points: :desc)
         haml :upvote
      end

      # for handling todos
      post '/:team/todo/new/' do
        team = params[:team]
        todo = Todo.new
        todo.user_name = @unique_id
        todo.content = params[:content]
        todo.flag = params[:flag] == "0" ? 'like' : 'wish'
        todo.team = team
        #binding.pry
        if todo.valid?
          todo.save
          redirect '/'+team
        end
      end


      ['/:team/todo/delete/:todo_id', '/:team/all/todo/delete/:todo_id'].each do | path | 
        post path do 
          # ...
          team = params[:team]
          #binding.pry
          todo = Todo.find_by(id: params[:todo_id], user_name: @unique_id)
          obsolete = User.find_by(voted_todo: params[:todo_id])
          user = User.find_by(voted_todo: params[:todo_id], username: @unique_id)
          #binding.pry

          if not todo.nil?
            todo.destroy
            if not obsolete.nil?
              obsolete.destroy
            end
            if not user.nil?
              user.destroy
            end
          end
          redirect '/'+team
        end 
      end 

      # post '/:team/todo/delete/:todo_id' do
      # end

      ['/:team/todo/vote/:todo_id', '/:team/all/todo/vote/:todo_id'].each do | path | 
        post path do 
          team = params[:team]
          user = User.find_by(voted_todo: params[:todo_id], username: @unique_id)
          #binding.pry
          if user.nil?
            todo = Todo.find_by(id: params[:todo_id])
            todo.update(:points => todo.points + 1)
            todo.save
            user = User.new
            user.username = @unique_id
            user.voted_todo = params[:todo_id]
            user.save
          end
          todo.to_json
         end 
       end    

      # post '/:team/todo/vote/:todo_id' do
      # end 


      get '/download' do 
        @todos = Todo.all
        haml :download
      end
      
      get '/download.json' do
        content_type :json
        @todos = Todo.select("content, flag, points, team").order(points: :desc)
        @todos.to_json
      end

      Spreadsheet.client_encoding = 'UTF-8'
      book = Spreadsheet::Workbook.new
      sheet1 = book.create_worksheet :name => 'test'

      post '/spreadsheet' do
        todos = Todo.all.order(points: :desc)
        todos.each do |todo|
          App.increment()
          sheet1.row(App.count()).push todo.content, todo.flag, todo.points, todo.team
        end
        book.write 'test.xls'
      end

end




