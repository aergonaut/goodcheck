require_relative "test_helper"

class JSONReporterTest < Minitest::Test
  Reporters = Goodcheck::Reporters
  Rule = Goodcheck::Rule
  Issue = Goodcheck::Issue
  Buffer = Goodcheck::Buffer

  include Outputs

  def test_reporter
    reporter = Reporters::JSON.new(stdout: stdout, stderr: stderr)

    reporter.analysis do
      reporter.file Pathname("foo.txt") do
        rule = Rule.new(id: "id", patterns: [], message: "Message", justifications: ["reason1", "reason2"], globs: [], fails: [], passes: [])
        reporter.rule rule do
          buffer = Buffer.new(path: Pathname("foo.txt"), content: "a b c d e")
          issue = Issue.new(buffer: buffer, range: 0..2, rule: rule, text: "a ")
          reporter.issue(issue)
        end
      end
    end

    assert_match /#{Regexp.escape "Checking foo.txt..."}/, stderr.string
    assert_match /#{Regexp.escape "Checking id..."}/, stderr.string

    json = JSON.parse(stdout.string, symbolize_names: true)

    assert_equal [{ rule_id: "id",
                    path: "foo.txt",
                    location: {
                      start_line: 1,
                      start_column: 0,
                      end_line: 1,
                      end_column: 2,
                    },
                    message: "Message",
                    justifications: ["reason1", "reason2"]
                  }], json
  end
end
