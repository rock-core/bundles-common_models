# frozen_string_literal: true

require "gnuplot"
require "pocolog"
require "scripts/aggregator/plots"

file = Pocolog::Logfiles.open(ARGV.first)
if stream_name = ARGV[1]
    stream = file.stream(stream_name)
else
    stream = file.stream_from_type("/aggregator/TimestampEstimatorStatus")
end

def timestamp(time, base_time)
    (time - base_time) * 1000
end

latencies = Plot.new("Latencies")
latencies.register(:latency, with: "lines")
latencies.register(:est_diff, with: "lines")
latencies.register(:raw_diff, with: "lines")

drops = Plot.new("Drops")
drops.register(:total, with: "lines")
drops.register(:current, with: "lines")
drops.register(:rejected, with: "lines")

time = Plot.new("Raw Times Differences")
time.register(:raw, with: "lines")
time.register(:est, with: "lines")
time.register(:reference, with: "lines")
time.register(:period, with: "lines")

base = Plot.new("Base Time Resets")
base.register(:resets, with: "lines")

base_time = nil
last_stats = nil
stream.samples.each do |_, _, stats|
    unless base_time
        if stats.time_raw.to_f == 0
            next
        else
            base_time = stats.time_raw
        end
    end

    x = stats.stamp - base_time

    if stats.reference_time_raw.to_f != 0
        latencies.data(:latency, [x, stats.latency.to_f * 1000])
        latencies.data(:est_diff, [x, timestamp(stats.stamp, stats.reference_time_raw)])
        latencies.data(:raw_diff, [x, timestamp(stats.time_raw, stats.reference_time_raw)])

        if last_stats && (last_stats.reference_time_raw.to_f != 0)
            time.data(:raw, [stats.time_raw - base_time, stats.time_raw - last_stats.time_raw])
            time.data(:est, [stats.stamp - base_time, stats.stamp - last_stats.stamp])
            time.data(:reference, [stats.reference_time_raw - base_time, stats.reference_time_raw - last_stats.reference_time_raw])
            time.data(:period, [stats.period.to_f * 1000, stats.stamp - last_stats.stamp])
        end
    end

    if last_stats
        offset = stats.base_time_reset_offset.to_f
        if offset > 3 * stats.period.to_f / 4
            offset -= stats.period.to_f
        end
        base.data(:resets, [x, offset])
    end

    drops.data(:total, [x, stats.lost_samples_total])
    drops.data(:current, [x, stats.lost_samples])
    drops.data(:rejected, [x, stats.rejected_expected_losses])
    last_stats = stats
end

latencies.show
drops.show
time.show
base.show
