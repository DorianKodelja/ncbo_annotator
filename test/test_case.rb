require "ontologies_linked_data"
require_relative "../lib/ncbo_annotator"
require_relative "../config/config.rb"

# Check to make sure you want to run if not pointed at localhost
safe_host = Regexp.new(/localhost|ncbo-dev*|ncbo-unittest*|ncbo-stg-app-22*/)
unless LinkedData.settings.goo_host.match(safe_host) && LinkedData.settings.search_server_url.match(safe_host) && Annotator.settings.annotator_redis_host.match(safe_host)
  print "\n\n================================== WARNING ==================================\n"
  print "** TESTS CAN BE DESTRUCTIVE -- YOU ARE POINTING TO A POTENTIAL PRODUCTION/STAGE SERVER **\n"
  print "Servers:\n"
  print "triplestore -- #{LinkedData.settings.goo_host}\n"
  print "search -- #{LinkedData.settings.search_server_url}\n"
  print "redis annotator -- #{Annotator.settings.annotator_redis_host}:#{Annotator.settings.annotator_redis_port}\n"
  print "Type 'y' to continue: "
  $stdout.flush
  confirm = $stdin.gets
  if !(confirm.strip == 'y')
    abort("Canceling tests...\n\n")
  end
  print "Running tests..."
  $stdout.flush
end

require 'minitest/unit'
MiniTest::Unit.autorun

class AnnotatorUnit < MiniTest::Unit

  def self.ontologies
    @@ontologies
  end

  def before_suites
    # code to run before the very first test
    LinkedData::SampleData::Ontology.delete_ontologies_and_submissions
    @@ontologies = LinkedData::SampleData::Ontology.sample_owl_ontologies
    @@sty = LinkedData::SampleData::Ontology.load_semantic_types_ontology
    annotator = Annotator::Models::NcboAnnotator.new
    annotator.init_redis_for_tests()
    annotator.create_term_cache_from_ontologies(@@ontologies, true)
    annotator.redis_switch_instance()
  end

  def after_suites
    # code to run after the very last test
    LinkedData::SampleData::Ontology.delete_ontologies_and_submissions
  end

  def _run_suites(suites, type)
    begin
      before_suites
      super(suites, type)
    ensure
      after_suites
    end
  end

  def _run_suite(suite, type)
    begin
      suite.before_suite if suite.respond_to?(:before_suite)
      super(suite, type)
    ensure
      suite.after_suite if suite.respond_to?(:after_suite)
    end
  end
end
MiniTest::Unit.runner = AnnotatorUnit.new

##
# Base test class. Put shared test methods or setup here.
class TestCase < MiniTest::Unit::TestCase
end
