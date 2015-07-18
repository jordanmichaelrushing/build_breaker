require 'net/http'
require 'json'
require 'clockwork'

include Clockwork

puts "STARTING BUILD LIGHT MONITOR"
circle_token = ENV['CIRCLE_TOKEN']
circle_url = "https://circleci.com/api/v1/organization/secondrotation?circle-token=#{circle_token}&shallow=true&offset=0&limit=30" # CIRCLE CI BUILD STATUS
hue_token = ENV['HUE_TOKEN']
hue_user = 'obbappuser'
hue_url="https://www.meethue.com/api/sendmessage?token=#{hue_token}"
greenCommand="{\"clipCommand\":{\"url\":\"/api/#{hue_user}/groups/0/action\",\"method\":\"PUT\",\"body\":{\"on\":true,\"bri\":255,\"sat\":255,\"hue\":25500}}}"
greenFlashCommand="{\"clipCommand\":{\"url\":\"/api/#{hue_user}/groups/0/action\",\"method\":\"PUT\",\"body\":{\"on\":true,\"bri\":255,\"sat\":255,\"hue\":25500, \"alert\":\"lselect\"}}}"
yellowCommand="{\"clipCommand\":{\"url\":\"/api/#{hue_user}/groups/0/action\",\"method\":\"PUT\",\"body\":{\"on\":true,\"bri\":255,\"sat\":255,\"hue\":12750}}}"
blueCommand="{\"clipCommand\":{\"url\":\"/api/#{hue_user}/groups/0/action\",\"method\":\"PUT\",\"body\":{\"on\":true,\"bri\":255,\"sat\":255,\"hue\":46920}}}"
redCommand="{\"clipCommand\":{\"url\":\"/api/#{hue_user}/groups/0/action\",\"method\":\"PUT\",\"body\":{\"on\":true,\"bri\":255,\"sat\":255,\"hue\":0 }}}"
redFlashCommand="{\"clipCommand\":{\"url\":\"/api/#{hue_user}/groups/0/action\",\"method\":\"PUT\",\"body\":{\"on\":true,\"bri\":255,\"sat\":255,\"hue\":0, \"alert\":\"lselect\"}}}"
offCommand="{\"clipCommand\":{\"url\":\"/api/#{hue_user}/groups/0/action\",\"method\":\"PUT\",\"body\":{\"on\":false,\"bri\":255,\"sat\":255,\"hue\":25500}}}"

command = nil

every(15.seconds, 'Checking builds'){
  do_exit = false
  build_status_map = {}
  resp = Net::HTTP.get_response(URI.parse(circle_url))
  resp_text = resp.body
  #puts resp_text
  recent_builds = JSON.parse(resp_text)
  recent_builds.reverse_each do |build|
    reponame = build['reponame']
    branch = build['branch']
    status = build['status']
    committer = build['committer_name']
    stopped_at = build['stop_time']
    #puts "#{reponame} #{branch} #{status}"
    key = "#{reponame}:#{branch}"
    #puts key
    build_status_map[key] = status
  end

  puts build_status_map

  if Time.now.hour >= 2 && Time.now.hour <=10 
    command_to_issue = offCommand
    do_exit = true
  elsif recent_builds[0]['status'] == 'failed'
    command_to_issue = redFlashCommand
    latest_breaker = `curl -H "Content-Type: application/json" -X GET -d '{"token":"helloGazelleWorld"}' https://buildbreaker.herokuapp.com/breaker`
    if latest_breaker['success'] && Time.parse latest_breaker['breaker']['broken_at'] != Time.parse(recent_builds[0]['committer_date'])
      `curl -H "Content-Type: application/json" -X POST -d '{"name":"#{recent_builds[0]['committer_name']}","broken_at":"#{Time.parse(recent_builds[0]['committer_date'])}","token":"helloGazelleWorld"}' https://buildbreaker.herokuapp.com/breaker`
    end
    recent_builds[0]['status']
  elsif build_status_map.has_value?('failed')
    command_to_issue = redCommand
  elsif build_status_map.has_value?('running')
    command_to_issue = blueCommand
  else
    command_to_issue = greenCommand
  end

  puts "Issuing command #{command_to_issue}"
  res = Net::HTTP.post_form(URI.parse(hue_url), 'clipmessage' => command_to_issue)
  puts res.body
 

  if do_exit
    Signal.trap 'TERM' do
      puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
      Process.kill 'QUIT', Process.pid
    end

    defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!
    exit
  end  
}