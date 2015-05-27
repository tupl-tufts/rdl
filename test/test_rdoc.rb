require 'minitest/autorun'
require 'rdoc'
require 'erb'
require 'fileutils'
require 'pathname'
require 'pp'
require 'tempfile'
require 'tmpdir'

require 'rdoc'
require_relative '../lib/rdl.rb'

class RdocTest < MiniTest::Test

  class TestClass
    extend RDL
    
    typesig :size, "()->Fixnum"
    typesig :bytesize, "()->Fixnum"
  end

  def test_rdoc_gen
    skip "TEST WITH NO ASSERTIONS"
    rdocTypesigFor(TestClass)
  end
end

class TestRDLRDoc
=begin
    @have_encoding = Object.const_defined? :Encoding
    @RM = RDoc::Markup
    RDoc::Markup::PreProcess.reset
    @pwd = Dir.pwd
    @store = RDoc::Store.new
    @rdoc = RDoc::RDoc.new
    @rdoc.store = @store
    @rdoc.options = RDoc::Options.new
    
    g = Object.new
    def g.class_dir() end
    def g.file_dir() end
    @rdoc.generator = g
    
    @lib_dir = "#{@pwd}/lib"
    $LOAD_PATH.unshift @lib_dir # ensure we load from this RDoc
    
    @options = RDoc::Options.new
    @options.option_parser = OptionParser.new
    
    p Dir.tmpdir
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
    klass = @top_level.add_class RDoc::NormalClass, 'RDL_TEST_Klass(String)'

    alis_constant = RDoc::Constant.new 'ABC', nil, ''
    alis_constant.record_location @top_level

    @top_level.add_constant alis_constant

    klass.add_module_alias klass, 'AAA', @top_level

    meth = RDoc::AnyMethod.new nil, 'Size'
    tmthd = String.instance_variable_get(:@__typesigs)[:size]
    msig = "()->#{tmthd.ret}"
    eval "
    def meth.param_seq
        return \"%s\"
    end
    def meth.comment
        true
    end
    def meth.description
        return \"%s\"
    end
" % [msig,"Takes input {Params} and outputs {Return}"]

    meth_bang = RDoc::AnyMethod.new nil, 'method!'
    attr = RDoc::Attr.new nil, 'attr', 'RW', ''

    klass.add_method meth
    klass.add_method meth_bang
    klass.add_attribute attr

    ignored = @top_level.add_class RDoc::NormalClass, 'Ignored'
    ignored.ignore

    #@store.complete :private

    @object      = @store.find_class_or_module 'Object'
    klass_alias = @store.find_class_or_module 'Klass::A'

    top_level = @store.add_file 'file.rb'
    top_level.add_class klass.class, klass.name

    @g.generate
    p File.file?('index.html')
=end
end
