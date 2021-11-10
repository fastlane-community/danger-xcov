module Danger
  # Validates the code coverage of the files changed within a Pull Request and
  # generates a brief coverage report.
  #
  # @example Validating code coverage for EasyPeasy (easy-peasy.io)
  #
  #    # Checks the coverage for the EasyPeasy scheme within the specified
  #    # workspace, ignoring the target 'Demo.app' and setting a minimum
  #    # coverage percentage of 90%.
  #   
  #    # The result is sent to the pull request with a markdown format and
  #    # notifies failure if the minimum coverage threshold is not reached.
  #
  #    xcov.report(
  #      scheme: 'EasyPeasy',
  #      workspace: 'Example/EasyPeasy.xcworkspace',
  #      exclude_targets: 'Demo.app',
  #      minimum_coverage_percentage: 90
  #    )
  #
  # @tags xcode, coverage, xccoverage, tests, ios, xcov
  # @see nakiostudio/danger-xcov
  #
  class DangerXcov < Plugin
    # Validates the code coverage of the files changed within a Pull Request.
    # This method accepts the same arguments allowed by the xcov gem.
    #
    # @param   args Hash{Symbol => String}
    #          This method accepts the same arguments accepted by the xcov gem.
    #          A complete list of parameters allowed is available here:
    #          https://github.com/nakiostudio/xcov
    # @return  [void]
    #
    def report(*args)
      begin
        # Run xcov to produce a processed report
        report = produce_report(*args)
        # Output the processed report
        output_report(report)
      rescue => e
        markdown("Xcov not run due to error: #{e}")
      end
    end

    # Produces and processes a report for use in the report method
    # It takes the same arguments as report, and returns the same
    # object as process_report
    def produce_report(*args)
      # Check xcov availability, install it if needed
      `gem install xcov` unless xcov_available?
      unless xcov_available?
        puts "xcov is not available on this machine"
        return
      end

      require "xcov"
      require "fastlane_core"

      # Init Xcov
      config = FastlaneCore::Configuration.create(Xcov::Options.available_options, convert_options(args.first))
      Xcov.config = config
      Xcov.ignore_handler = Xcov::IgnoreHandler.new

      # Init project
      report_json = nil
      manager = Xcov::Manager.new(config)

      if Xcov.config[:html_report] || Xcov.config[:markdown_report] || Xcov.config[:json_report]
        # Parse .xccoverage and create local report
        report_json = manager.run
      else
        # Parse .xccoverage
        report_json = manager.parse_xccoverage
      end

      # Map and process report
      process_report(Xcov::Report.map(report_json))
    end

    # Outputs a processed report with Danger
    def output_report(report)
      # Create markdown
      report_markdown = report.markdown_value

      # Send markdown
      markdown(report_markdown)

      # Notify failure if minimum coverage hasn't been reached
      threshold = Xcov.config[:minimum_coverage_percentage].to_i
      if !threshold.nil? && (report.coverage * 100) < threshold
        fail("Code coverage under minimum of #{threshold}%")
      end
    end

    # Aux methods

    # Checks whether xcov is available
    def xcov_available?
      `which xcov`.split("/").count > 1
    end

    # Filters the files that haven't been modified in the current PR
    def process_report(report)
      file_names = @dangerfile.git.modified_files.map { |file| File.expand_path(file) }
      file_names += @dangerfile.git.added_files.map { |file| File.expand_path(file) }
      report.targets.each do |target|
        target.files = target.files.select { |file| file_names.include?(file.location) }
      end

      report
    end

    # Processes the parameters passed to the plugin
    def convert_options(options)
      converted_options = options.dup
      converted_options.delete(:verbose)
      converted_options
    end

    private :xcov_available?, :process_report

  end
end
