require 'rdoc'
require 'erb'
require 'fileutils'
require 'pathname'

class TestRDLRDoc
    # TODO: Replicate binding for parser output or for template.result
    options = RDoc::Options.new
    options.generator = RDoc::Generator::Darkfish
    $LOAD_PATH.each do |path|
        darkfish_dir = File.join path, 'rdoc/generator/template/darkfish/'
        next unless File.directory? darkfish_dir
        options.template_dir = darkfish_dir
        break
    end
    options.template_dir += 'class.rhtml'
    p options.template_dir
    template = File.read options.template_dir
    file_var = File.basename(options.template_dir).sub(/\..*/, '')
    erbout = "_erbout_#{file_var}"
    template = ERB.new template, nil, '<>', erbout

    template.filename = options.template_dir.to_s
    #generator = options.generator.new store,options

    msig = RDoc::AnyMethod.new("",@mname)
    eval "
    def msig.param_seq
        return \"%s\"
    end" % ["HelloWorld!"]
    p msig.param_seq #rdoc_gen

    ctx = RDoc::Context.new
    ctx.add_method(msig)

    #template.result ctx.get_binding

end
