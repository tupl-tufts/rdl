module RDL::Annotate
    def openapi(path_to_openapi_spec)
        # Step 1. Read in JSON file.
        RDL::Logging.log :openapi, :info, "Typechecking Rails project against OpenAPI spec: #{path_to_openapi_spec}"
        file = File.read(path_to_openapi_spec)

        # Step 2. Parse JSON string to Ruby hash.
        openapi = JSON.parse(file)

        # Step 3. Ensure Rails is loaded.
        if !defined?(Rails)
            RDL::Logging.log :openapi, :error, "Tried to typecheck a Rails project against an OpenAPI spec, but Rails is not loaded. Please load Rails and try again."
        end

        # Step 4. Get paths for this Rails application.
        rails_paths = Rails.application.routes.routes.routes.map {|r| ActionDispatch::Routing::RouteWrapper.new(r)}.reject(&:internal?)


        # Step 5. Go through each path in the OpenAPI spec, and figure out:
        #         1. What Rails controller it belongs to
        #         2. What that method name is called
        #         3. what type this method has
        openapi["paths"].each_pair {|path, verbs|
            #puts "#{path}"# :: #{verbs}"

            path = path.tr("{}", "")

            # TODO: Support other HTTP verbs.
            route = Rails.application.routes.recognize_path(path)
            puts
            puts
            puts
            kontroller = "#{route[:controller]}_controller".camelize.constantize.new.class

            method = route[:action]

            ap "OpenAPI Path: #{path}. Resolved to Rails action: #{kontroller}##{method}"

            ap "Resolved output type: -> #{translate_schema(verbs['get']['responses']['200']['content']['application/json; charset=utf-8']['schema'], openapi)}"


        }


        #############
        # test area

        #puts
        #puts
        #puts
        #ap "Route:"
        #ap rails_paths[14]

        #puts
        #puts
        #puts
        #ap "Route Controller:"
        #ap rails_paths[14].controller

        #puts
        #puts
        #puts
        #ap "Route Action:"
        #ap rails_paths[14].action

        #puts
        #puts
        #puts
        #rails_paths.each { |p| 
        #    ap "#{p.controller}_controller".camelize.constantize.new.class
        #}
        #klass = "#{rails_paths[14].controller}_controller".camelize.constantize.new
        #ap "Route Class:"
        #ap klass

        #
        #############

        exit(1)
    end


    # Translates an OpenAPI schema to an RDL type.
    #
    # schema: OpenAPI schema (in JSON)
    # openapi: the entire OpenAPI spec (in JSON, used for #ref's)

    def translate_schema(schema, openapi)
        case schema['type']
        # Primitives
        when 'integer'
            'Integer'
        when 'float', 'double'
            'Float'
        when 'string'
            'String'

        # Arrays
        when 'array'
            "Array<#{translate_schema(schema['items'], openapi)}>"

        # Objects
        when 'object'
            schema.to_s # conservative approximation for JSON

        # Refs (reference to a schema defined elsewhere in the spec)
        # Refs have no "type", instead they have "$ref"
        when nil
            if schema["$ref"] != nil
                translate_schema(resolve_ref(schema["$ref"], openapi), openapi)

            else
                RDL::Logging.log :openapi, :error, "Schema missing 'type' or '$ref': #{schema}"
                throw ""

            end

        else
            "String" # conservative approximation for everything else. If it's coming from OpenAPI, it can definitely be represented as a string.
        end
    end

    # resolves a $ref within a schema.
    #
    # ref: a $ref string. Looks like "#/components/schemas/Talk"
    #
    def resolve_ref(ref, openapi)
        # First, ensure this is a local reference.
        # Remote references are a thing, but I don't think we will need to deal with them.
        # https://swagger.io/docs/specification/using-ref/

        if not ref[0] == '#'
            RDL::Logging.log :openapi, :error, "Tried to resolve a ref but it's not local. Only local ref's are supported at this time. Offending ref: #{ref}"
            throw ''
        end

        # Split the ref into its parts, and resolve them one at a time.
        # Ignoring the first part, which is the "#/"
        parts = ref.split('/').drop(1)

        resolved = openapi

        # Iterate through the parts, and keep digging down until we resolve the full schema path
        parts.each { |part|
            resolved = resolved[part]
        }

        resolved
    end
end