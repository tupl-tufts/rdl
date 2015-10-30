# Introduction

RDL is a lightweight system for adding contracts to Ruby. A *contract*
decorates a method with assertions describing what the method assumes
about its inputs (called a *precondition*) and what the method
guarantees about its outputs (called a *postcondition*). For example,
using RDL we can write

```
require 'rdl'

pre { |x| x > 0 }
post { |r,x| r > 0 }
def sqrt(x)
  # return the square root of x
end
```

to indicate the `sqrt` method assumes its input is positive and
returns and output that is positive. (Let's ignore complex numbers to
keep things simple...)

Contracts have been around for a long time. They originated with the
Eiffel programming language [cite], and have been...(XXX fill in history)

RDL contracts are enforced at method entry and exit. For example, if
we call `sqrt(49)`, RDL first checks that `49 > 0`; then it passes `49`
to `sqrt`, which (presumably) returns `7`; then RDL checks that `7 >
0`; and finally it returns `7`.

In addition to arbitrary pre- and post-conditions, RDL also has
extensive support for contracts that are *types*. For example, we can
write the following in RDL:

```
require 'rdl'

type '(Fixnum, Fixnum) -> String'
def m ... end
```

This indicates that `m` is that method that returns a `String` if
given two `Fixnum` arguments. Again this contract is enforced at
run-time: When `m` is called, RDL checks that `m` is given exactly
two arguments and both are `Fixnum`s, and that `m` returns an instance
of `String`. RDL supports many more complex type annotations; see
below for a complete discussion and examples.

RDL contracts and types are stored in memory at run time, so it's also
possible for programs to query them. RDL includes lots of contracts
and type for the core and standard libraries. Since those methods are
generally trustworthy, RDL doesn't actually enforce the contracts
(since that would add overhead), but they are available to search and
query. For example:

```
require 'rdl'
require 'rdl_types'

XXXfill in
```

XXXexplain above

# RDL Reference

## Supported versions of Ruby

RDL currently supports Ruby 2.2. It may or may not work with other
versions.

## Installing RDL

`gem install rdl` should do it.

## Loading RDL

Use `require 'rdl'` to load the RDL library. If you want to use the
core and standard library type signatures that come with RDL, follow
it with `require 'rdl_types'`.  This will load the types based on the
current `RUBY_VERSION`. Currently RDL has types for the following
versions of Ruby:

* 2.2.0
* 2.2.1 [same as 2.2.0]
* 2.2.2 [same as 2.2.0]
* 2.2.3 [same as 2.2.0]

If you're using Ruby on Rails, you can similarly `require
'rails_types'` to load in type annotations for the current
`Rails::VERSION::STRING`. More specifically, add the following lines
in `application.rb` after the `Bundler.require` call. (This placement
is needed so the Rails version string is available and the Rails
environment is loaded):

```
require 'rdl'
require 'rdl_types'
require 'rails_types'
```

Currently RDL has types for the following versions of Rails:

* Under development

## Preconditions and Postconditions

The `pre` method takes a block and adds that block as a precondition
to a method. When it's time to check the precondition, the block will
be called with the method's arguments. If the block returns `false` or
`nil` the precondition is considered to have failed, and RDL will
raise a `ContractError`. Otherwise the block is assumed to
succeed. The block can also raise its own error if the contract fails.

The `pre` method can be called in several ways:

* `pre { block }` - Apply precondition to the next method to be
defined
* `pre mth { block }` - Apply precondition to method `mth` of the current
class, where `m` is a `Symbol` or `String`
* `pre cls, mth { block }` - Apply precondition to method `mth` of class
  `cls`, where `cls` is a `Class`, `Symbol`, or `String`, and `mth` is a
  `Symbol` or `String`

The `post` method is similar, except its block is called with the
return value of the method (in the first position) followed by all the
method's arguments. For example, you probably noticed that for `sqrt`
above the `post` block took the return value `r` and the method
argument `x`.

(One minor subtlety: RDL does *not* clone or dup the arguments at
method entry, so if the method body has mutated, say, fields stored
inside those argument objects, the `post` block will see the mutated
field values rather than the original values.)

The `post` method can be called in the same ways as `pre`.

Methods can have no contracts, `pre` by itself, `post` by itself,
both, or multiple instances of either. If there are multiple
contracts, RDL checks that *all* contracts are satisfied.

## Type Signatures

The `type` method adds a type contract to a method. It supports the
same calling patterns as `pre` and `post`, except rather than a block,
it takes a string argument describing the type. More specifically,
`type` can be called as:

* `type 'typ'`
* `type m, 'typ'`
* `type cls, mth, 'typ'`

A type string generally has the form `(typ1, ..., typn) -> typ`
indicating a method that takes `n` arguments of types `typ1` through
`typn` and returns type `typ`. RDL supports the following kinds of
types:

* [Nominal Types]
* [Nil]
* [Top]
* [Union Types]
* [Intersection Types]
* [Optional Argument Types]
* [Varargs Types]
* [Annotated Argument Types]
* [Type Aliases]
* [Singletong Types]
* [Tuple Types]
* [Finite Hash Types]
* [Structural Types]

### Generic Types

type_params(params, all, variance)
instantiate!(*typs)
deinstantiate!

## Contract queries

XXXTodo

## Raw Contracts



## Other Methods

* rdl_alias(new_name, old_name)
* nowrap
* type_cast
* type_alias(name, typ)

## RDL Configuration

# Code Overview

# RDL Build Status

[![Build Status](https://travis-ci.org/plum-umd/rdl.png?branch=cRDL)](https://travis-ci.org/plum-umd/rdl)

# Bibliography



# TODO list

* ProcContract, Wrap, MethodType, support higher-order contracts for blocks
+ And higher-order type checking
+ Block passed to contracts don't work yet

* How to check whether initialize? is user-defined? method_defined? always
returns true, meaning wrapping isn't fully working with initialize.

* Currently if a NominalType name is expressed differently, e.g., A
  vs. EnclosingClass::A, the types will be different when compared
  with ==.

* Macros, %bool should really be %any

* Method types that are parametric themselves (not just ones that use
  enclosing class parameters)

* Rails types

* Proc types

* Deferred contracts on new (watch for class addition)

* DSL contracts

* Documentation!

* double-splat arguments, which bind to an arbitrary set of keywords.