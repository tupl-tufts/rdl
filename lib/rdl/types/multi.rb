module RDL::Type
    class MultiType < Type
        # @map Map<Path, Type>.
        attr_accessor :map

        class << self
        alias :__new__ :new
        end

        def self.new(map)
            # Two important things to do here.
            # 1. If any cases have a pi of `false`, that means they were 
            #    assigned (likely bottom) under an empty path (likely the 
            #    result of a return stmt).
            #    In this case, we will filter them out of the multi map.
            #    
            # 2. If there are no keys left in the multimap, simply return 
            #    bottom.

            map = map.filter { |p, t| !(p.class <= PathFalse) }
            if map.keys.size == 0
                return RDL::Globals.types[:bot]
            end

            # 1. Flatten nested MultiTypes (to oblivion).
            new_map = map.clone
            until new_map.none? { |p, t| t.is_a? MultiType } do

                # take multitypes out of new_map, put them in nested_multitypes
                # there must be a one liner to do this.
                nested_multitypes = new_map.filter { |p, t| t.is_a? MultiType }
                new_map.reject! { |p, t| t.is_a? MultiType }

                nested_multitypes.each { |outer_p, mt| 
                    # Merge paths and put the MultiType entries directly in new_map
                    nested_map = mt.map.transform_keys { |inner_p| PathAnd.new([outer_p, inner_p]) }
                    #new_map.merge!(nested_map)
                    new_map.merge!(nested_map) { |merged_p, outer_t, inner_t|
                        UnionType.new(outer_t, inner_t).canonical
                    }
                }
            end

            # 2. Prune unsatisfiable paths.
            new_map.filter! {|p, t| p.satisfiable? }

            keys = map.keys
            #return RDL::Globals.types[:bot] if keys.size == 0
            return map[keys[0]] if (keys.size == 1) && (keys[0] == PathTrue.new)

            return MultiType.__new__(new_map)
        end

        def initialize(map = {})
            @map = map
        end

        def canonical
            canonicalize!
            return @canonical if @canonical
            return self
        end

        def canonicalize!
            # not using canonicalization at the moment.
            # the first case causes many issues,
            # and the second is being handled by the constructor.

            # %bot will be extracted during solution if
            # a multitype with no entries makes it to that point

            #keys = @map.keys
            #if keys.size == 0
            #    @canonical = RDL::Globals.types[:bot] 
            #end
            #elsif keys.size == 1
            #    @canonical = map[keys[0]]
            #end
        end

        # Returns a Map<Array<Path>, Type>
        def type_map
            @map
        end

        # Index into this MultiType, assuming `path` holds.
        # path : Path
        def index(path)
            # Logic for this:
            # Indexing a MultiType by path could give us multiple things.
            # It could not match at all, in which case we return self.
            # It could fully match a key, in which case we return the value.
            # It could partially match a key(s), in which case we construct
            # a new MultiType with smaller keys.

            # Check for no match
            return self unless self.can_index?(path)

            # Index the keys of our map by `path`
            # TODO(Mark): 2024/09/13 Might need more boolean algebra here. Possibly a call to Z3? To see if a key in the path implies one of our keys.
            exact_matches = []
            @map.each { |k, v|
                if path == k
                    exact_matches.append(v)
                end
            }

            if exact_matches.length > 0
                # We have exact matches
                RDL::Type::UnionType.new(*exact_matches)
            end

            # Old code which is good, but doesn't work anymore.
            #exact_matches = [] # values of exactly matched keys
            #partial_matches = [] # [{k: Path, v: Type}] of partial matches
            #@map.each { |k, v|
            #    reduced = (k.conds - path.conds)
            #    if reduced.empty?
            #        exact_matches.append(v)
            #    else
            #        partial_matches.append({k: PathTrue.new(reduced), v: v})
            #    end
            #}

            #if exact_matches.length > 0
            #    # We have exact matches.
            #    return RDL::Type::UnionType.new(*exact_matches)
            #else
            #    # No exact matches. Return the indexed map as a new MultiType.
            #    return RDL::Type::MultiType.new(partial_matches)
            #end
        end

        def can_index?(path)
            #@map.has_key?(path)
            # self.type_map.keys.any? { |p| PathCondition.can_index?(path, p) }
            return @map.keys.any? { |p| p == path }
        end

        # placeholder
        def is_complete?
            true
        end

        # TODO: add `is_a?`, with a `pi` component. For `MP_case_generic`

        def inspect
            return "#{"MultiType".colorize(:blue)}{\\n" + @map.each_pair.map { |pi, t| "\t#{t}\n\t_{#{pi.inspect}}" }.join(",\n") + " }"
        end
        
        # to_s is just like #inspect but without the colors.
        def to_s
            return "#{"MultiType"}{\n" + @map.each_pair.map { |pi, t| "\t#{t}\n\t_{#{pi.to_s}}" }.join(",\n") + " }"
        end

        def ==(other)
            (other.is_a? MultiType) && (other.map == @map)
        end

        def copy
            MultiType.new(@map.clone)
        end

        def instantiate(inst)
            return MultiType.new(@map.transform_values {|t| t.instantiate(inst)})
        end

    end
end