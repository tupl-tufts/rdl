module FileUtils
  rdl_nowrap

  type 'self.cp_r', '(String or Pathname, String or Pathname, ?Hash<:preserve or :noop or :verbose or :dereference_root or :remove_destination, %bool>) -> Array<String>'
  type 'self.mkdir_p', '(String or Pathname, ?Hash<:mode or :noop or :verbose, %bool>) -> Array<String>'
end
