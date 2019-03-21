
require 'fugit'; p Fugit::VERSION

cron = Fugit.parse('5 * * * * *')
p cron

puts
t0 = Time.now
puts
p cron.previous_time
p Time.now - t0; t0 = Time.now
puts
p cron.previous_time
p Time.now - t0
puts
