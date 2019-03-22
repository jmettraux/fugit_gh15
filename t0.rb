
require 'fugit'; p Fugit::VERSION

#cron = Fugit.parse('5 * * * * *')
cron = Fugit.parse('10 * * * * *')

p cron.previous_time(Time.now.utc)

