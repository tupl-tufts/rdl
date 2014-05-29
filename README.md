# Introduction

# Typesigs

## Generating Typesigs

spec :mthd_name do
	typesig "ANNOTATION"
end


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

| API call | Meaning |
| --- | --- |
| `spec` | a |
| `keyword` |
| `dsl` |
| `arg` |
| `pre_cond { block }` |
| `pre_task { block }` |
| `post_cond { block }` |
| `post_task { block }` |
| `dsl_from { block }` |
| `Spec.new` |
| `ret_dep` |
