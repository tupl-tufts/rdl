class Class
  type 'allocate', '() -> %any' # Instance of class self
  type 'inherited', '(Class) -> %any'
  #type 'initialize', '() -> '
  #type 'new', '(*%any) -> %any' #Causes two other test cases to fail
  type 'superclass', '() -> Class or nil'
end
