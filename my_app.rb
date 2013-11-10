require 'rubygems'
require 'sinatra'
require 'data_mapper'
require 'rack-flash'

enable :sessions	
use Rack::Flash

DataMapper.setup(:default, "sqlite3:///#{Dir.pwd}/my_db.db")

class User
	include DataMapper::Resource

	property :id,		Serial
	property :login,	String
	property :password,	String

	has n, :visits

	def self.auth(login, pass)
		User.first(login: login, password: pass)
	end
end

class Visit
	include DataMapper::Resource

	property :id,			Serial
	property :created_at,	DateTime

	belongs_to :user
end

DataMapper.finalize.auto_upgrade!

User.first_or_create(
	login: 		"misha",
	password: 	"pass"
	)

['/users', '/'].each do |path|
	before path do
		redirect '/login' unless session[:login]
	end
end

get '/' do
	@user = User.first(login: session[:login])
	@visits = @user.visits.all
	erb :'index'
end

get '/login' do
	erb :'login'
end

post '/login' do
	if session[:login] = User.auth(params["login"], params["pass"]).login
		flash[:notice] = "Hello"
		#add visit
		User.first(login: session[:login]).visits.create(created_at: Time.now)
		redirect '/'
	else
		flash[:notice] = "Wrong"
		redirect '/login'
	end
end