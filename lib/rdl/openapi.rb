# This file is responsible for translating OpenAPI specs (.json files)
# into RDL types, to typecheck against Rails API code.

module RDL::Annotate
    # Typecheck this Rails project against an OpenAPI spec.
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
        rails_paths = Rails.application.routes.routes.map {|r| ActionDispatch::Routing::RouteWrapper.new(r)}.reject(&:internal)


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

            output_type = translate_path(verbs, openapi)
            ap "Resolved type: #{output_type}}"
            output_type_rdl = RDL::Wrap.type_to_type output_type
            ap "Resolved RDL type: #{output_type_rdl}}"

            # Actually perform the typechecking.
            ap "Submitting to RDL: RDL.type, #{kontroller}, #{method.to_sym}, #{output_type}}"
            RDL.type kontroller, method.to_sym, output_type, wrap: false, typecheck: :openapi


        }

        RDL.do_typecheck :openapi

        RDL::Logging.log :openapi, :info, "Successfully type-checked against OpenAPI spec!"

    end

    # Translates an OpenAPI path to an RDL type.
    # Currently, only supports GET endpoints with a 200 response.
    def translate_path(endpoint, openapi)
        input_type = "{}"
        input_type = "{#{translate_parameters(endpoint['get']['parameters'], openapi)}}" if endpoint['get'].has_key?('parameters')

        output_type = translate_responses(endpoint['get']['responses'], openapi)

        "(#{input_type}) -> #{output_type}"
    end

    # Translates an OpenAPI `parameters` field to an RDL type,
    # representing the endpoint's input type.
    def translate_parameters(parameters, openapi)
        # Map each parameter type to its RDL type, then concatenate them and join with ", ".
        parameters.map {|p| 
            # Symbol to add, if the parameter is optional
            opt = "?"
            opt = "" if p.has_key?('required') && (p['required'] == true)
            "#{p['name']}: #{opt}#{translate_schema(p['schema'], openapi)}"
        }.join(', ')
    end

    # Translates an OpenAPI `responses` field to an RDL type, 
    # representing the endpoint's output type.
    # Currently, only supports a 200 response.
    def translate_responses(responses, openapi)
        RDL::Logging.log :openapi, :error, "OpenAPI spec doesn't have a 200 response: #{responses}" if !responses.has_key?('200')

        response_content = responses['200']['content']

        # Check if response_content has a key that starts with `application/json`. If so, extract the `schema` from within that, and pass it to `translate_schema`.
        # Otherwise, return `nil`.
        json_content = response_content.keys.find {|k| k.start_with?('application/json')}

        if json_content != nil
            translate_schema(response_content[json_content]['schema'], openapi)
        else
            nil
        end

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
            if RDL::Config.instance.number_mode
                'Integer'
            else
                'Float'
            end
        when 'string'
            '(String or Symbol)'

        # Arrays
        when 'array'
            throw "Array schema missing `items` field: #{schema}" unless schema['items']
            "Array<#{translate_schema(schema['items'], openapi)}>"

        # Objects
        when 'object'
            throw "Object schema missing `properties` field: #{schema}" unless schema['properties']

            fields = schema['properties'].map {|k, v| 
                # Symbol to add, if the property is optional
                opt = "?"
                opt = "" if schema.has_key?('required') && schema['required'].include?(k)
                "#{k}: #{opt}#{translate_schema(v, openapi)}"
            }.join(', ')

            "JSON<{#{fields}}>"

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
            #"String" # conservative approximation for everything else. If it's coming from OpenAPI, it can definitely be represented as a string.
            # but I'll crash for now
            RDL::Logging.log :openapi, :error, "Unknown field in OpenAPI definition: #{schema}"
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