file = 'sample_appysphere.log'

class AppyParse
  def parse(file)
    File.readlines(file).each do |line|
      puts line
    end
  end

  def parseIO(file)
    IO.foreach(file) do |line|
      puts line
    end
  end
end

ap = AppyParse.new

t1 = Time.now
ap.parse(file)
t2 = Time.now
time = t2 - t1
puts "file parsed with File in #{time}ms"


iot1 = Time.now
ap.parseIO(file)
iot2 = Time.now
timeIO = iot2 - iot1
puts "file parsed with IO in #{timeIO}ms"
