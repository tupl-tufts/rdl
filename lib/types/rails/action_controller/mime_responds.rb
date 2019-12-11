RDL.nowrap :'ActionController::MimeResponds'

RDL.type :'ActionController::MimeResponds', :respond_to,
'(?(String or Symbol)) { (ActionController::MimeResponds::Collector) -> %any } -> Array<String> or String'

module ActionController
  module MimeResponds
    class Collector
      Mime::EXTENSION_LOOKUP.each { |mime|
        RDL.type :'ActionController::MimeResponds::Collector', :method_missing,
          "(#{mime[1].symbol.inspect}) { (?ActionController::MimeResponds::Collector::VariantCollector) -> %any } -> %any"
      }
    end
  end
end
