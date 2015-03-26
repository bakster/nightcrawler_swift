module NightcrawlerSwift
  class Sync < Command

    def initialize
      @upload = Upload.new
      @logger = NightcrawlerSwift.logger
    end

    def execute dir_path
      @logger.info "[NightcrawlerSwift] dir_path: #{dir_path}"
      files = Dir["#{dir_path}/**/**"]
      files = files.reject { |files| files.match(escaped_folder) } unless options.skipped_folder.empty?

      p = Pool.new(20)

      files.each do |fullpath|
        p.schedule do
          path = fullpath.gsub("#{dir_path}/", "")
          unless File.directory?(fullpath)
            @logger.info "[NightcrawlerSwift] #{path}"
            @upload.execute path, File.open(fullpath, "r")
          end
        end
      end

      at_exit { p.shutdown }
    end

    private

    def escaped_folder
      text = options.skipped_folder
      %r{#{text}/|/#{text}}
    end

  end

end
