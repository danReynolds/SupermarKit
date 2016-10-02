module Matcher
    class Matcher
        include Amatch

        SIMILARITY_THRESHOLD = 0.45
        AGGREGATE_SIMILARITY_THRESHOLD = 0.9

        class Match
            attr_accessor :similarity, :result

            def initialize(args)
                @similarity = args[:similarity]
                @result = args[:result]
            end
        end

        def initialize(pattern)
            @comparator = Levenshtein.new(pattern)
        end

        def find_match(objects, threshold = SIMILARITY_THRESHOLD, key = nil)
            match = objects.inject({ similarity: 0 }) do |acc, obj|
              similarity = key ? @comparator.similar(obj.send(key)) : @comparator.similar(obj)

                acc.tap do |acc|
                    if (acc[:similarity] < similarity) && similarity >= threshold
                        acc.merge!({
                            similarity: similarity,
                            result: obj
                        })
                    end
                end
            end
            match[:similarity] ? Match.new(match) : nil
        end
    end
end
