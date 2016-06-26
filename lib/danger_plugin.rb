module Danger
  # Validates the code coverage of the files changed within a Pull Request.
  # This method accepts the same arguments accepted by the xcov gem.
  #
  # @example Validating code coverage for EasyPeasy (easy-peasy.io)
  #
  #  xcov.report(
  #    scheme: 'EasyPeasy',
  #    workspace: 'Example/EasyPeasy.xcworkspace',
  #    exclude_targets: 'Demo.app',
  #    minimum_coverage_percentage: 90
  #  )
  #
  #  # Checks the coverage for the EasyPeasy scheme within the specified
  #  workspace, ignoring the target 'Demo.app' and setting a minimum
  #  coverage percentage of 90%.
  #  The result is sent to the pull request with a markdown format and
  #  notifies failure if the minimum coverage threshold is not reached.
  #
  # @see: https://github.com/nakiostudio/danger-xcov
  # @tags: xcode, coverage, xccoverage, tests, ios, xcov
  class DangerXcov < Plugin

    # Validates the code coverage of the files changed within a Pull Request and
    # generates a brief coverage report.
    #
    # @param   Hash{Symbol => String} parameters
    #          This method accepts the same arguments accepted by the xcov gem.
    #          A complete list of allowed parameters is available here:
    #          https://github.com/nakiostudio/xcov
    # @return  [void]
    def report(*args)
      # Check xcov availability, install it if needed
      `gem install xcov` unless xcov_available
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

      # Notify failure if minimum coverage hasn't been reached
      threshold = config[:minimum_coverage_percentage].to_i
      if !threshold.nil? && (report.coverage * 100) < threshold
        fail("Code coverage under minimum of #{threshold}%")
      end
    end

    # Class methods

    # Brief description of the plugin
    # @return  [String]
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
