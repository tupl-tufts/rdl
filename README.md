# Introduction

# Typesigs

## Generating Typesigs

```
spec :mthd_name do
	typesig "ANNOTATION"
end
```


## Annotation Syntax

"( arg0, arg1, … argN ) { Annotation } -> Type" ### Method Arguments, Block, and Return


## Argument Syntax

"Type …" ### Standard Argument
"typevar …" ### Lowercase Type Variable for Generic Types
"?Type …" ### Optional Argument
"*Type …" ### Variable Number of Arguments (Splat)


## Type Syntax

"… Class" ### Standard Type Definition
"… :sym" ### Symbol
"… %any" ### Type Placeholder (Any Type)
"… %bool" ### Boolean Value (TrueClass and FalseClass)
"… Type0 OR Type1" ### Union Types

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
