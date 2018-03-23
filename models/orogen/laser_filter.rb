require 'common_models/models/blueprints/sensors'
require 'common_models/models/blueprints/devices'

class OroGen::LaserFilter::Task
    provides Base::LaserRangeFinderSrv, :as => 'filtered_scans'

    transformer do
        associate_frame_to_ports 'laser', 'filtered_scans'
    end

end

module Base

    class FilteredLaserRangeFinder < Syskit::Composition
        add Base::LaserRangeFinderSrv, :as => 'source'
        add LaserFilter::Task, :as => 'filter'

        source_child.scans_port.connect_to filter_child.scan_samples_port

        export filter_child.filtered_scans_port
        provides Base::LaserRangeFinderSrv, :as => 'filtered_scans'
    end

end

