require 'stackprof'

module Vic20
  class Processor
    module Profile
      def run
        profile = StackProf.run(mode: :cpu, interval: 1000, raw: true) do
          begin
            super
          rescue Vic20::Processor::Trap => e
            STDERR.puts e.message
          end
        end

        StackProf::Report.new(profile).print_text
      end
    end
  end
end
