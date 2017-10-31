#!/usr/bin/ruby

cat_api_key = 'MjMyMTUx'
cat_api_url = 'http://thecatapi.com/api/images/get?format=xml&results_per_page=1'

require 'sinatra'
require 'json'
require 'net/http'
require 'crack'
require 'redis'

redis = Redis.new(host: "localhost", port: 6379)

get '/cat' do
  uri = URI(cat_api_url)
  xmlcontent = Net::HTTP.get(uri)
  rubyhash = Crack::XML.parse(xmlcontent)

  image = Hash.new
  image['image'] = {
    "url"         => rubyhash['response']['data']['images']['image']['url'],
    "id"          => rubyhash['response']['data']['images']['image']['id'],
    "source_url"  => rubyhash['response']['data']['images']['image']['source_url']
   }

  redisdata = {
    "url"         => rubyhash['response']['data']['images']['image']['url'],
    "id"          => rubyhash['response']['data']['images']['image']['id'],
    "source_url"  => rubyhash['response']['data']['images']['image']['source_url']
  }

  redis.set(rubyhash['response']['data']['images']['image']['id'] , redisdata.to_json )


  JSON.pretty_generate(image)
  #image.to_json

end

get '/history' do

  response = Hash.new
  response['images'] = Array.new

  rediskeys = redis.keys('*')

   rediskeys.each { | key |

     puts "Keyname: #{key} Value: " + redis.get(key)
     response['images'].push JSON.parse(redis.get(key))
   }

  JSON.pretty_generate(response)
  #response.to_json

end
