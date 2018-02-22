require 'awesome_print'
require 'time'
file = 'sample_appysphere.log'

class AppyParse
  include Enumerable

  public

  def parseIO(file)
    # init hash with nested arrays
    output_camera_ip_calls_by_home = Hash.new {|h,k| h[k] = Hash.new(0) }
    output_service_times_ranking = Array.new()

    response_times = {
      'get_camera'      => [],
      'get_home'        => [],
      'get_all_cameras' => [],
      'POST_user_id'    => [],
      'GET_user_id}'    => []
    }

    lines_read = 0
    IO.foreach(file).grep(/\/api\/users\/[0-9]*(\/(get_camera|get_home|get_all_cameras))?[[:blank:]]/) do |line|
      entry = parse_entry(line)
      endpoint = entry['endpoint']
      _method = entry['_method']
      response_time = entry['response_time']

      # Collect data respective to endpoint
      if endpoint == 'get_camera'
        response_times['get_camera'] << response_time
        id = entry['home_id']
        ip = entry['ip_camera']
        output_camera_ip_calls_by_home[id][ip] += 1

        output_service_times_ranking << {
          'ip'            => ip,
          'id'            => id,
          'response_time' => response_time
        }
      elsif endpoint == 'get_home'
        response_times['get_home'] << response_time
      elsif endpoint == 'get_all_cameras'
        response_times['get_all_cameras'] << response_time
      elsif _method == 'POST' && endpoint == nil
        response_times['POST_user_id'] << response_time
      elsif _method == 'GET' && endpoint == nil
        response_times['GET_user_id'] << response_time
      end

      lines_read += 1
    end

    # Create schema and populate values for response times output
    output_response_times = {
      'get_camera'      => {
        'mean'    => find_mean(response_times['get_camera']),
        'median'  => find_median(response_times['get_camera']),
        'mode'    => find_mode(response_times['get_camera']),
      },
      'get_home'        => {
        'mean'    => find_mean(response_times['get_home']),
        'median'  => find_median(response_times['get_home']),
        'mode'    => find_mode(response_times['get_home']),
      },
      'get_all_cameras'        => {
        'mean'    => find_mean(response_times['get_all_cameras']),
        'median'  => find_median(response_times['get_all_cameras']),
        'mode'    => find_mode(response_times['get_all_cameras']),
      },
      'POST_user_id'        => {
        'mean'    => find_mean(response_times['POST_user_id']),
        'median'  => find_median(response_times['POST_user_id']),
        'mode'    => find_mode(response_times['POST_user_id']),
      },
      'GET_user_id'        => {
        'mean'    => find_mean(response_times['GET_user_id']),
        'median'  => find_median(response_times['GET_user_id']),
        'mode'    => find_mode(response_times['GET_user_id']),
      }
    }

    output_service_times_ranking.sort_by! { |hash| hash['response_time'] }

    output = {
      # The number of times every camera was called segmented per home.
      'camera_ip_calls_by_home' => output_camera_ip_calls_by_home,
      # The mean (average), median and mode of the response time (connect time + service time) for this URL's
      'response_times'          => output_response_times,
      # Ranking of the devices (get camera) (per service time)
      'service_times_ranking'   => output_service_times_ranking,
      'entries_processed'       => lines_read
    }

    return output
  end

  private

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

  def find_median(array)
    if !array.is_a?(Array) then return nil end
    sorted = array.sort
    len = sorted.length
    median = (sorted[(len - 1) / 2] + sorted[len / 2]) / 2.0
    return median
  end

  def find_mean(array)
    if !array.is_a?(Array) then return nil end
    sum = array.inject(0, :+)
    mean = sum/array.length
    return mean
  end

  def find_mode(array)
    if !array.is_a?(Array) then return nil end
    freq = array.inject(Hash.new(0)) { |h,v| h[v] += 1; h }
    mode = array.max_by { |v| freq[v] }
    return mode
  end

end

ap = AppyParse.new

# t1 = Time.now
# ap.parse(file)
# t2 = Time.now
# time = t2 - t1
# puts "file parsed with File in #{time}ms"

iot1 = Time.now
ap ap.parseIO(file)
iot2 = Time.now
timeIO = iot2 - iot1
puts "File parsed with IO in #{timeIO}ms"
