# frozen_string_literal: true

module Gitlab
  module Ci
    class Trace
      class Metrics
        extend Gitlab::Utils::StrongMemoize

        OPERATIONS = [
          :appended,  # new trace data has been written to a chunk
          :streamed,  # new trace data has been sent by a runner
          :chunked,   # new trace chunk has been created
          :mutated,   # trace has been mutated when removing secrets
          :overwrite, # runner requested overwritting a build trace
          :accepted,  # scheduled chunks for migration and responded with 202
          :finalized, # all live build trace chunks have been persisted
          :discarded, # failed to persist live chunks before timeout
          :conflict,  # runner has sent unrecognized build state details
          :locked,    # build trace has been locked by a different mechanism
          :stalled,   # failed to migrate chunk due to a worker duplication
          :invalid    # malformed build trace has been detected using CRC32
        ].freeze

        def increment_trace_operation(operation: :unknown)
          unless OPERATIONS.include?(operation)
            raise ArgumentError, "unknown trace operation: #{operation}"
          end

          self.class.trace_operations.increment(operation: operation)
        end

        def increment_trace_bytes(size)
          self.class.trace_bytes.increment({}, size.to_i)
        end

        def self.trace_operations
          strong_memoize(:trace_operations) do
            name = :gitlab_ci_trace_operations_total
            comment = 'Total amount of different operations on a build trace'

            Gitlab::Metrics.counter(name, comment)
          end
        end

        def self.trace_bytes
          strong_memoize(:trace_bytes) do
            name = :gitlab_ci_trace_bytes_total
            comment = 'Total amount of build trace bytes transferred'

            Gitlab::Metrics.counter(name, comment)
          end
        end
      end
    end
  end
end
