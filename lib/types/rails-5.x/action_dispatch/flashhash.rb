class ActionDispatch::Flash::FlashHash
  type(:[], "(Symbol) -> String")
  type(:[]=, "(Symbol, String) -> String")
  type(:now, "() -> ActionDispatch::Flash::FlashNow")
end

class ActionDispatch::Flash::FlashNow
  type(:[], "(Symbol) -> String")
  type(:[]=, "(Symbol, String) -> String")
end
