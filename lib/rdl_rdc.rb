module RDL

class RDLdocObj
    def initialize()
        @klasses = {}
        if (not $RDLdoc) then
            initOnce()
        end
        return $RDLdoc
    end
    
    def initOnce()
        # Borrowed from RDoc Test Case
        @have_encoding = Object.const_defined? :Encoding
        @RM = RDoc::Markup
        RDoc::Markup::PreProcess.reset
        @pwd = Dir.pwd
        @store = RDoc::Store.new
        @rdoc = RDoc::RDoc.new
        @rdoc.store = @store
        
        @lib_dir = "#{@pwd}/lib"
        $LOAD_PATH.unshift @lib_dir # ensure we load from this RDoc
        
        @options = RDoc::Options.new
        @options.option_parser = OptionParser.new
        
        puts "Output Directory:  %s" %[Dir.tmpdir]
        @tmpdir = File.join Dir.tmpdir, "test_rdoc_generator_darkfish_#{$$}"
        FileUtils.mkdir_p @tmpdir
        Dir.chdir @tmpdir
        @options.op_dir = @tmpdir
        @options.generator = RDoc::Generator::Darkfish
        
        $LOAD_PATH.each do |path|
            darkfish_dir = File.join path, 'rdoc/generator/template/darkfish/'
            next unless File.directory? darkfish_dir
            @options.template_dir = darkfish_dir
            break
        end
        
        @rdoc.options = @options
        
        @g = @options.generator.new @store, @options
        @rdoc.generator = @g
        
        @top_level = @store.add_file 'file.rb'
        @top_level.parser = RDoc::Parser::Ruby
        

    end

    def add_klass(kls)
        rdocklass = @klasses[kls.to_s]
        if(rdocklass.nil?) then
           rdocklass = @top_level.add_class RDoc::NormalClass, kls.to_s
           
        end
        
        kls.instance_variable_get(:@__typesigs).each{|mname,mthd| rdocklass.add_method( add_method(mname.to_s,mthd) )}
        
        
        
        @klasses[kls.to_s] = rdocklass
    end


    # TODO
    def add_alias()
        #alias_constant = RDoc::Constant.new 'ABC', nil, ''
        #alias_constant.record_location @top_level
        #@top_level.add_constant @alias_constant
        #klass.add_module_alias @klass, 'AAA', @top_level
        #klass_alias = @store.find_class_or_module 'Klass::A'
    end

    # TODO
    def add_ignore()
        #ignored = @top_level.add_class RDoc::NormalClass, 'Ignored'
        #ignored.ignore
    end

    # TODO
    def add_attribute()
        #attr = RDoc::Attr.new nil, 'attr', 'RW', ''
        #@klass.add_attribute attr
    end

    def add_method(mname,tsinfo)
        mthd = RDoc::AnyMethod.new nil,mname
        msig = "("
        desc = "Takes input {Params} and outputs {Return}"
        
        tsinfo.args.each{|arg| msig +=arg; msig +=",";}
        if(msig[-1]==",")then
            msig = msig[0...-1]
        end
        msig += ")"
        if tsinfo.block then
            msig += "{|| BLOCK}"
        end
        msig += " -> "
        msig += tsinfo.ret.to_s
        
        puts "Generated Method Signature: %s" %[msig]
        
        eval "
        def mthd.param_seq
            return \"%s\"
        end
        def mthd.comment
            true
        end
        def mthd.description
            return \"%s\"
        end
        " % [msig,desc]

        return mthd

    end
private :initOnce, :add_alias, :add_ignore, :add_method, :add_attribute

    def rdoc_gen()
        
        
        #@store.complete :private
        @object = @store.find_class_or_module 'Object'
        #@top_level.add_class klass.class, klass.name
        @g.generate
        puts "Successful?: %s" %[File.file?('index.html').to_s]
    end
end

end