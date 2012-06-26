module Sunspot
  module Solr
    class Server
      attr_writer :multicore

      # Do not set the data dir as it conflicts with multicore datadir.

      def solr_data_dir
        File.expand_path(@solr_data_dir || Dir.tmpdir) unless is_multicore?
      end

      def is_multicore?
        @multicore
      end

      # Create new solr_home, config, log and pid directories

      def create_solr_directories
        # Do not create new solr_data_dir, this is multicore.
        dirs = is_multicore? ? [pid_dir] : [solr_data_dir, pid_dir]
        dirs.each do |path|
          FileUtils.mkdir_p(path) unless File.exists?(path)
        end
      end
    end
  end
end
