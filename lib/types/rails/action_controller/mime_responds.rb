module ActionController
  module MimeResponds
    type :respond_to, '(*(String or Symbol)) { (ActionController::MimeResponds::Collector) -> %any } -> Array<String> or String'

    class Collector
      Mime::EXTENSION_LOOKUP.each { |mime|
        type :method_missing, "(#{mime[1].symbol.inspect}) { (ActionController::MimeResponds::Collector::VariantCollector) -> %any } -> %any"
      }
    end
  end
end
