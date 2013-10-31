require 'rubygems'
require 'sinatra'
require 'data_mapper'
	
   # An in-memory Sqlite3 connection:
DataMapper.setup(:default, 'sqlite::memory:')

class User
	include DataMapper::Resource

	property :id,		Serial
	property :login,	String
	property :password,	String
end

DataMapper.finalize.auto_upgrade!

@user = User.create(
	login: 		"misha",
	password: 	"pass"
)
@user.save

get '/users' do
	@users = User.all
	erb :'users/index'
end