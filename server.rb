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
        response.set_cookie 'user-id',
         {:value=> session[:id], :max_age => "1210000", :httponly => true }
         #binding.pry
         @team = params[:team]
         #binding.pry
         @todos = Todo.all.order(points: :desc)
         haml :index
      end

      get '/download' do 
        @todos = Todo.all
        haml :download
      end
      
      get '/download.json' do
        content_type :json
        @todos = Todo.select("content, flag, points").order(points: :desc)
        @todos.to_json
      end

      # for handling todos
      post '/todo/new/' do
        todo = Todo.new
        todo.user_name = @unique_id
        todo.content = params[:content]
        todo.flag = params[:flag] == "0" ? 'like' : 'wish'
        #binding.pry
        
        if todo.valid?
          todo.save
          redirect '/'
        end
      end

      post '/todo/delete/:todo_id' do
        todo = Todo.find_by(id: params[:todo_id], user_name: @unique_id)
        user = User.find_by(voted_todo: params[:todo_id], username: @unique_id)
        #binding.pry

        if not todo.nil?
          todo.destroy
          if not user.nil?
            user.destroy
          end
        end

        redirect '/'
      end

      post '/todo/vote/:todo_id' do 
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
        #redirect '/'
      end 

      Spreadsheet.client_encoding = 'UTF-8'
      book = Spreadsheet::Workbook.new
      sheet1 = book.create_worksheet :name => 'test'

      post '/spreadsheet' do
        todos = Todo.all.order(points: :desc)
        todos.each do |todo|
          App.increment()
          sheet1.row(App.count()).push todo.content, todo.flag, todo.points
        end

        book.write 'test.xls'
      end

end




