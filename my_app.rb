require 'rubygems'
require 'sinatra'
require 'data_mapper'

enable :sessions	

DataMapper.setup(:default, "sqlite3:///#{Dir.pwd}/my_db.db")

class User
	include DataMapper::Resource

	property :id,		Serial
	property :login,	String
	property :password,	String
end

DataMapper.finalize.auto_upgrade!
=begin
@user = User.create(
	login: 		"misha",
	password: 	"pass"
)
@user.save
=end
['/users', '/'].each do |path|
	before path do
		redirect '/login' unless session[:user]
	end
end

get '/users' do
	@users = User.all
	erb :'users/index'
end

get '/'  do
	"Main page!"
end


get '/login' do
	"Let's login"
end