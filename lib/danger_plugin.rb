module Danger
  class DangerXcov < Plugin

    def run(*args)
      # Check xcov availability, install it if needed
      system "gem install xcov" unless xcov_available
      unless xcov_available
        puts "xcov is not available on this machine"
        return
      end

      require "xcov"

      # Init Xcov
      config = args.first
      Xcov.config = config
      Xcov.ignore_handler = Xcov::IgnoreHandler.new

      # Init project
      FastlaneCore::Project.detect_projects(config)
      Xcov.project = FastlaneCore::Project.new(config)

      # Parse .xccoverage
      report_json = Xcov::Runner.new.parse_xccoverage

      # Map and process report
      report = process_report(Xcov::Report.map(report_json))

      # Create markdown
      report_markdown = report.markdown_value

      # Send markdown
      markdown(report_markdown)
    end

    # Class methods

    def self.description
      "Danger plugin to validate the code coverage of the files changed"
    end

    # Aux methods

    # Checks whether xcov is available
    def xcov_available
      `which xcov`.split("/").count > 1
    end

    # Filters the files that haven't been modified in the current PR
    def process_report(report)
      file_names = modified_files.map { |file| File.basename(file) }
      report.targets.each do |target|
        target.files = target.files.select { |file| file_names.include?(file.name) }
      end

      report
    end

    private :xcov_available, :process_report

  end
end
