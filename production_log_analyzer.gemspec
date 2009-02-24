Gem::Specification.new do |s|
  s.name = %q{production_log_analyzer}
  s.version = "2009022403"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Eric Hodel"]
  s.date = %q{2009-02-24}
  s.description = %q{production_log_analyzer provides three tools to analyze log files created by SyslogLogger.  pl_analyze for getting daily reports, action_grep for pulling log lines for a single action and action_errors to summarize errors with counts.}
  s.email = %q{drbrain@segment7.net}
  s.executables = ["action_errors", "action_grep", "pl_analyze"]
  s.extra_rdoc_files = ["History.txt", "LICENSE.txt", "Manifest.txt", "README.txt"]
  s.files = ["History.txt", "LICENSE.txt", "Manifest.txt", "README.txt", "Rakefile", "bin/action_errors", "bin/action_grep", "bin/pl_analyze", "lib/production_log/action_grep.rb", "lib/production_log/analyzer.rb", "lib/production_log/parser.rb", "test/test.syslog.0.14.x.log", "test/test.syslog.1.2.shortname.log", "test/test.syslog.empty.log", "test/test.syslog.log", "test/test_action_grep.rb", "test/test_analyzer.rb", "test/test_parser.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://seattlerb.rubyforge.org/production_log_analyzer}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{seattlerb}
  s.rubygems_version = %q{1.2.0}
  s.summary = %q{production_log_analyzer lets you find out which actions on a Rails site are slowing you down.}
  s.test_files = ["test/test_action_grep.rb", "test/test_analyzer.rb", "test/test_parser.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if current_version >= 3 then
      s.add_runtime_dependency(%q<rails_analyzer_tools>, [">= 1.4.0"])
      s.add_development_dependency(%q<hoe>, [">= 1.8.3"])
    else
      s.add_dependency(%q<rails_analyzer_tools>, [">= 1.4.0"])
      s.add_dependency(%q<hoe>, [">= 1.8.3"])
    end
  else
    s.add_dependency(%q<rails_analyzer_tools>, [">= 1.4.0"])
    s.add_dependency(%q<hoe>, [">= 1.8.3"])
  end
end
