# Introduction

# Typesigs

## Generating Typesigs

```
extend RDL
typesig :method_name, “ANNOTATION”, {Optional Hash of Parameterized Types}, *Additional_Contracts
#eg typesig :foo, “(Array<t>)->Array<t>”, {:t}, pre{|arr| arr.size<5}, post{|ret| ret.size<3}, post{|ret| ret.foobar}
```


## Annotation Syntax

```
# ( Method Arguments   ) { Block      } -> Return
" ( arg0, arg1, … argN ) { Annotation } -> Type" 
```

## Argument Syntax
```
# Standard Argument
"Type …"

# Optional Argument
"?Type …"

# Variable Number of Arguments (Splat)
"*Type …"
```

## Type Syntax
```
# Standard Type Definition
"… Class"

# Parameterized Type
“Type<t> …”, {:t}

# Symbol Equivalence
"… :sym" 

# Type Placeholder (any Type)
"… %any" 

# Boolean Value (TrueClass and FalseClass)
"… %false”
“… %true”

# Nil Value (NilClass)
“… nil”
 
# Union Types
"… Type0 or Type1"

# Labeling (for reference in Contracts)
“… Label:Type”
```

## Contracts
```
<span style="color:red">TODO</span>
```

## Generating RDoc
```
rdocTypesigFor(Klass)
```



# RDL Quick Reference

* `spec :method { block }` - Apply contracts in `block` to existing `method`
* `keyword :method { block }` - Define new `method` with contracts in `block`
* `dsl { block }` - Define a DSL where `spec`s and `keyword`s inside `block` may be used within the block argument of the method being contracted.
* `action { |args| block }` - Set `block` to be the body of the method being contracted (valid only within `keyword`), taking `args` as arguments.
* `pre_cond { |args| block }` - Invoke `block` before executing the method being contracted, and abort if the block returns `false` or `nil`. The method arguments are passed as `args`.
* `pre_task { |args| block }` - <span style="color:red">FIXME</span>
* `post_cond { |args, ret| block }` - Invoke `block` after executing the method being contracted, and abort if the block returns `false` or `nil`. The method arguments and return values are passed as `args`.
* `post_task { block }` - <span style="color:red">FIXME</span>
* `dsl_from { block }` - <span style="color:red">FIXME</span>
* `arg` - <span style="color:red">FIXME</span>
* `ret` - <span style="color:red">FIXME</span>
* `ret_dep` - <span style="color:red">FIXME</span>
* `Spec.new` - <span style="color:red">FIXME</span>
