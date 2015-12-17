module Base64
  rdl_nowrap

  type 'self.decode64', '(String) -> String'
  type 'self.encode64', '(String) -> String'
  type 'self.strict_decode64', '(String) -> String'
  type 'self.strict_encode64', '(String) -> String'
  type 'self.urlsafe_decode64', '(String) -> String'
  type 'self.urlsafe_encode64', '(String) -> String'
end
