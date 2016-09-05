module Matcher
    class Matcher
        include Amatch

        SIMILARITY_THRESHOLD = 0.45
        AGGREGATE_SIMILARITY_THRESHOLD = 0.9

        class Match
            attr_accessor :similarity, :name

            def initialize(args)
                @similarity = args[:similarity]
                @name = args[:name]
            end
        end

        def initialize(pattern)
            @comparator = Levenshtein.new(pattern)
        end

        def find_match(objects, threshold = SIMILARITY_THRESHOLD)
            match = objects.inject({}) do |acc, obj|
                similarity = @comparator.similar(obj)
                acc.tap do |acc|
                    if (acc[:similarity].nil? || acc[:similarity] < similarity) && similarity >= threshold
                        acc.merge!({
                            similarity: similarity,
                            name: obj
                        })
                    end
                end
            end
            match[:similarity] ? Match.new(match) : nil
        end
    end
end
