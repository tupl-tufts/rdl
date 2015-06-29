# RDL Build Status

[![Build Status](https://travis-ci.org/plum-umd/rdl.png?branch=cRDL)](https://travis-ci.org/plum-umd/rdl)

# What is RDL?

RDL is a Ruby library designed for the annotation of Ruby code with run-time contracts. The RDL Typesig System is a user annotation shortcut for generating Type Contracts. RDL’s Domain Specific Language functionality further provides syntactic sugar for creating DSL contexts, while RDL’s RubyDoc support helps export Typesig and Contract information to html format.

# How to use RDL

## Writing Typesigs
```
class MyClass
  extend RDL

  def my_method …

  typesig :method_name, “ANNOTATION”, {Optional Hash of Parameterized Types}, *Additional_Contracts
  #i.e. typesig :my_method, “(Array<t>)->Array<t>”, {:t}, pre{|arr| arr.size<5}, post{|ret| ret.size<3}, post{|ret| ret.foobar}
```


### Annotation Syntax
```
#               ( Method Arguments     ) { Block      } -> Return
typesig :foo, ” ( arg0Type, … argNType ) { Annotation } -> ReturnType " 

```

### Argument Syntax
```
# Standard Argument
"Type …"

# Optional Argument
"?Type …"

# Variable Number of Arguments (Splat)
"*Type …"
```

### Type Syntax
```
# Standard Type Definition
"… Type”

# Parameterized Type
“Type<t> …”, {:t}

# Symbol Value
"… :sym" 

# Type Placeholder (any Type)
"… %any" 

# Boolean Value (TrueClass and FalseClass)
"… %bool”

# Nil Value (NilClass)
“… nil”
 
# Union Types
"… Type0 or Type1"

# Labeling (for reference in Contracts)
“… Label:Type”
```

## Using Contracts
```
# Basic Contract
contract = FlatCtc.new(“My Contract Description”) {|…| …}

# Precondition Contract
precond = pre(“My Precondition”) {|…| …}

# Postcondition Contract
postcond = post(“My Postcondition”) {|…| …}

# Bind Contract
spec :my_method_name do

  # Add contract with Contract object
  pre “Additional Description”, precond
  post “Additional Descripton”, postcond

  # Create and add contract from Block
  pre_cond(“My Precondition”) {|…| …}
  post_cond(“My Postcondition”) {|…| …}

end

# Check Contract
contract.check()
```

## Creating DSLs
```
dsl do

  # Create new keyword
  keyword :action {…}

  # Create and store nested dsl
  nested_dsl = dsl do
    …
  end

  # Include keywords from other dsl
  extend other_dsl

  # Use previously declared del context
  nested_dsl.apply {…}

end
```

## Generating RDoc
```
rdocTypesigFor(Klass) # Deprecated FIXME
```

## RDL Quick Reference

* TODO

# TODO list

* ProcContract, Wrap, MethodType, support higher-order contracts for blocks

* FlatContract, labeled arguments?

* GenericType, fix member? to check type parameters

* Tuple and hash types

* How to check whether initialize? is user-defined? method_defined? always
returns true, meaning wrapping isn't fully working with initialize

* Check in instantiate! that array contents matches instantiated type