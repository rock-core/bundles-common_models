# frozen_string_literal: true

require "gnuplot"
#
# plot = PositionPlot.new('test')
# plot.register( :centroid, {:title => "Particle Filter"} )
# plot.register( :gps, {:title => "GPS", :lt => -1} )
# plot.register( :odometry, {:title => "Odometry"} )
#
# # now do multiples of
# plot.data( :centroid, row )
# plot.data( :odometry, row )
# plot.data( :gps, [row[0],row[1]], [row[3],row[4]] )
#
# # you can either save, or show the plot
# plot.save( ARGV[1] )
#

class Plot
    def initialize(title)
        @title = title

        @plots = {}
    end

    def register(sym, params = {})
        @plots[sym] = {}
        @plots[sym][:value] = [[], []]
        @plots[sym][:error] = [[], []]
        @plots[sym].merge!(params)
        @plots[sym][:title] ||= sym.to_s
    end

    def data(sym, value, error = nil)
        @plots[sym][:value][0] << value[0]
        @plots[sym][:value][1] << value[1]
        if error
            @plots[sym][:error][0] << (2 * error[0])
            @plots[sym][:error][1] << (2 * error[1])
        end
    end

    def save(file_name)
        File.open(file_name, "w") do |file|
            plot(file)
        end
    end

    def show
        Gnuplot.open do |gp|
            plot(gp)
        end
    end

    def plot(gp)
        Gnuplot::Plot.new(gp) do |plot|
            plot.set "title '#{@title}' font 'Helvetica,20'"
            plot.set "key spacing 1.5"
            plot.set "key font 'Helvetica,14'"
            plot.set "key right bottom"

            # plot.arbitrary_lines  "set ylabel \"y label" font \"Helvetica,20\""

            plots = []
            obj_idx = 1

            @plots.each_value do |p|
                p[:error][0].length.times do |i|
                    plot.object "#{obj_idx} ellipse center #{p[:value][0][i]}, #{p[:value][1][i]} size #{p[:error][0][i]},#{p[:error][1][i]}  fs empty border #{p[:lt]}"
                    obj_idx += 1
                end

                unless p[:value][0].empty?
                    plots << Gnuplot::DataSet.new(p[:value]) { |ds|
                        p.each do |key, value|
                            if key != :value && key != :error
                                ds.send("#{key}=", value)
                            end
                        end
                    }
                end
            end

            plot.data = plots
        end
    end
end
