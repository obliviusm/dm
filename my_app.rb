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
	attr_accessor :password_confirmation

	has n, :visits
	validates_uniqueness_of :login
	validates_confirmation_of :password
	validates_length_of :login, :min => 3
	validates_presence_of :login
	validates_presence_of :password

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
	p params
	if session[:login] = User.auth(params["login"], params["pass"]).login
		flash[:notice] = "Hello, " + session[:login].to_s
		#add visit
		User.first(login: session[:login]).visits.create(created_at: Time.now)
		redirect '/'
	else
		flash[:error] = "Wrong login/pass"
		redirect '/login'
	end
end

get '/logout' do
	session[:login] = nil
	flash[:notice] = "Log out successful"
	redirect '/login'
end

get '/signup' do
	erb :'signup'
end

post '/signup' do
	user = User.new(login: params[:login], password: params[:pass], 
		password_confirmation: params[:pass_conf])
	if user.save
		session[:login] = User.auth(params["login"], params["pass"]).login
		flash[:notice] = "Hello, " + session[:login].to_s
		User.first(login: session[:login]).visits.create(created_at: Time.now)
		redirect '/'
	else
		flash[:error] = user.errors.full_messages
		redirect '/signup'
	end
end