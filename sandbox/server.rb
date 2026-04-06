require 'sinatra'
require 'json'
require 'open3'
require 'fileutils'

GAME_DIR  = '/game'
DONT_RB   = "#{GAME_DIR}/dont.rb"
PLAYER_CODE = "#{GAME_DIR}/player_code.rb"
RUNNER    = '/app/runner.rb'

set :port,       4567
set :bind,       '0.0.0.0'
set :logging,    false
disable :protection

get '/source' do
  content_type :json
  { source: File.read(DONT_RB) }.to_json
end

post '/eval' do
  data = JSON.parse(request.body.read)
  File.write(PLAYER_CODE, data['code'])

  stdout, stderr, status = Open3.capture3("ruby #{RUNNER}")

  content_type :json
  {
    exit_code: status.exitstatus,
    stdout:    stdout,
    stderr:    stderr,
    source:    File.read(DONT_RB)
  }.to_json
end

post '/reset' do
  FileUtils.cp("#{DONT_RB}.original", DONT_RB)
  content_type :json
  { ok: true }.to_json
end
