
#require 'active_support/core_ext/time'
#require 'active_support/core_ext/date'
#require 'active_support/core_ext/date_time'
#require 'active_support/time'
#require 'active_support'

#p Time.class.ancestors
  #
  # On @conet's platform it looks like:
  #
  # [ Time, DateAndTime::Compatibility, DateAndTime::Calculations,
  #    DateAndTime::Zones, Comparable, NakayoshiFork::Behavior,
  #    ActiveSupport::ToJsonWithActiveSupportEncoder, Object,
  #    GettextI18nRails::HtmlSafeTranslations, FastGettext::Translation,
  #    ERB::Util, PP::ObjectMixin, ActiveSupport::Dependencies::Loadable,
  #    ActiveSupport::Tryable, JSON::Ext::Generator::GeneratorMethods::Object,
  #    Kernel, BasicObject ]

require 'fugit'; p Fugit::VERSION

class Fugit::Cron

  def previous_time(from=::EtOrbi::EoTime.now)

    from = ::EtOrbi.make_time(from)
    ti = 0
    ifrom = from.to_i

    t = TimeCursor.new(from.translate(@timezone))
    stalling = false
    i = -1

    loop do

      i = i + 1
      ti1 = t.to_i

      if i % 10_000 == 0
        log({
          i: i, t: t_to_s(t.time), q: ti1 == ti, d: ti1 - ti,
          from: t_to_s(from), c: original, tz: @timezone,
          df: from.to_i - ti1 })
      end

      fail RuntimeError.new(
        "loop stalled for #{@original.inspect} #previous_time, breaking"
      ) if stalling && ti == ti1

      stalling = (ti == ti1)
      ti = ti1

      fail RuntimeError.new(
        "too many loops for #{@original.inspect} #previous_time, breaking"
      ) if (ifrom - ti).abs > BREAKER_S

      (ifrom == ti) && (t.inc(-1); next)
      month_match?(t) || (t.dec_month; next)
      day_match?(t) || (t.dec_day; next)
      hour_match?(t) || (t.dec_hour; next)
      min_match?(t) || (t.dec_min; next)
      sec_match?(t) || (t.dec_sec(@seconds); next)
      break
    end

    t.time.translate(from.zone)
  end

  protected

  def t_to_s(time=Time.now)

    time.strftime('%Y%m%dT%H%M%S') + sprintf('.%06dZ', time.usec)
  end

  def log(o)

    p o.inspect
        #
    #puts(
    #  "#{t_to_s} #{Thread.current.name.inspect} " +
    #  "Fugit#previous_time \\ #{o.inspect}")
        #
        # Maybe @godfat could help here, not sure how to access the logger...
        #
    #logger.warn { "Fugit#previous_time \\ #{o.inspect}" }
  end
end

#cron = Fugit.parse('5 * * * * *')
cron = Fugit.parse('10 * * * * *')

puts
t = cron.previous_time.to_f# + 0.123 (some float x so that 0.0 <= x < 1.0)
puts
cron.previous_time(Time.at(t))
puts

