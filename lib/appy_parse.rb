require 'awesome_print'
require 'time'
file = 'sample_appysphere.log'

class AppyParse
  include Enumerable

  def parseIO(file)
    # init hash with nested arrays
    camera_ip_calls_by_home = Hash.new {|h,k| h[k] = Hash.new(0) }

    response_times = {
      'get_camera'      => [],
      'get_home'        => [],
      'get_all_cameras' => [],
      'POST_user_id'    => [],
      'GET_user_id}'    => []
    }

    lines_read = 0
    IO.foreach(file).grep(/\/api\/users\/[0-9]*\/(get_camera?|get_home?|get_all_cameras?)/) do |line|
      entry = parse_entry(line)
      endpoint = entry['endpoint']
      _method = entry['_method']
      response_time = entry['response_time']

      ap entry

      # The number of times every camera was called segmented per home.
      if entry['endpoint'] == 'get_camera'
        response_times['get_camera'] << response_time
        id = entry['home_id']
        ip = entry['ip_camera']
        camera_ip_calls_by_home[id][ip] += 1
      elsif endpoint == 'get_home'
        response_times['get_home'] << response_time
      elsif endpoint == 'get_all_cameras'
        response_times['get_all_cameras'] << response_time
      elsif _method == 'POST'
        response_times['POST_user_id'] << response_time
      end



      # The mean (average), median and mode of the response time (connect time + service time) for this URL's

      # Ranking of the devices (get camera) (per service time)










      lines_read += 1
    end
    puts "#{lines_read} lines read"
    ap camera_ip_calls_by_home
  end

  def parse_entry(line)
    line            = line.split
    path            = line[4].split('=')[1]
    endpoint        = path.split('/')[4]
    connect         = line[8].split('=')[1].tr('ms','').to_i
    service         = line[9].split('=')[1].tr('ms','').to_i
    response_time   = service + connect

    entry = {
      'timestamp'     => Time.parse(line[0]),
      'router'        => line[1],
      'at'            => line[2].split('=')[1],
      '_method'       => line[3].split('=')[1],
      'path'          => path,
      'endpoint'      => endpoint,
      'host'          => line[5].split('=')[1],
      'ip_camera'     => line[6].split('=')[1].tr('"',''),
      'home_id'       => line[7].split('=')[1],
      'response_time' => response_time,
      'status'        => line[10].split('=')[1],
      'bytes'         => line[11].split('=')[1]
    }
    # ap entry
    return entry
  end

end

ap = AppyParse.new

# t1 = Time.now
# ap.parse(file)
# t2 = Time.now
# time = t2 - t1
# puts "file parsed with File in #{time}ms"

iot1 = Time.now
ap.parseIO(file)
iot2 = Time.now
timeIO = iot2 - iot1
puts "file parsed with IO in #{timeIO}ms"
