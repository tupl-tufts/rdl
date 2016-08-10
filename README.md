[![Gem Version](https://badge.fury.io/rb/rdl.svg)](https://badge.fury.io/rb/rdl) [![Build Status](https://travis-ci.org/plum-umd/rdl.svg?branch=master)](https://travis-ci.org/plum-umd/rdl)


# Table of Contents

* [Introduction](#introduction)
* [Using RDL](#using-rdl)
  * [Supported versions of Ruby](#supported-versions-of-ruby)
  * [Installing RDL](#installing-rdl)
  * [Loading RDL](#loading-rdl)
  * [Disabling RDL](#disabling-rdl)
  * [Preconditions and Postconditions](#preconditions-and-postconditions)
  * [Type Annotations](#type-annotations)
* [RDL Types](#rdl-types)
  * [Nominal Types](#nominal-types)
  * [Nil Type](#nil-type)
  * [Top Type (%any)](#top-type-any)
  * [Union Types](#union-types)
  * [Intersection Types](#intersection-types)
  * [Optional Argument Types](#optional-argument-types)
  * [Variable Length Argument Types](#variable-length-argument-types)
  * [Named Argument Types](#named-argument-types)
  * [Dependent Types](#dependent-types)
  * [Higher-order Types](#higher-order-types)
  * [Class/Singleton Method Types](#classsingleton-method-types)
  * [Structural Types](#structural-types)
  * [Singleton Types](#singleton-types)
  * [Self Type](#self-type)
  * [Type Aliases](#type-aliases)
  * [Generic Class Types](#generic-class-types)
  * [Tuple Types](#tuple-types)
  * [Finite Hash Types](#finite-hash-types)
  * [Type Casts](#type-casts)
  * [Bottom Type (%bot)](#bottom-type-bot)
  * [Non-null Type](#non-null-type)
* [Static Type Checking](#static-type-checking)
  * [Types for Variables](#types-for-variables)
  * [Tuples, Finite Hashes, and Subtyping](#tuples-finite-hashes-and-subtyping)
  * [Other Features and Limitations](#other-features-and-limitations)
  * [Assumptions](#assumptions)
* [Other RDL Methods](#other-rdl-methods)
* [Queries](#queries)
* [Configuration](#configuration)
* [Bibliography](#bibliography)
* [Copyright](#copyright)
* [Contributors](#contributors)
* [TODO List](#todo-list)

# Introduction

RDL is a lightweight system for adding contracts to Ruby. A *contract* decorates a method with assertions describing what the method assumes about its inputs (called a *precondition*) and what the method guarantees about its outputs (called a *postcondition*). For example, using RDL we can write

```ruby
require 'rdl'

pre { |x| x > 0 }
post { |r,x| r > 0 }
def sqrt(x)
  # return the square root of x
end
```

Given this program, RDL intercepts the call to `sqrt` and passes its argument to the `pre` block, which checks that the argument is positive. Then when `sqrt` returns, RDL passes the return value (as `r`) and the initial argument (as `x`) to the `post` block, which checks that the return is positive. (Let's ignore complex numbers to keep things simple...)

RDL contracts are enforced at method entry and exit. For example, if we call `sqrt(49)`, RDL first checks that `49 > 0`; then it passes `49` to `sqrt`, which (presumably) returns `7`; then RDL checks that `7 > 0`; and finally it returns `7`.

In addition to arbitrary pre- and post-conditions, RDL also has extensive support for contracts that are *types*. For example, we can write the following in RDL:

```ruby
require 'rdl'

type '(Fixnum, Fixnum) -> String'
def m(x,y) ... end
```

This indicates that `m` is that method that returns a `String` if given two `Fixnum` arguments. Again this contract is enforced at run-time: When `m` is called, RDL checks that `m` is given exactly two arguments and both are `Fixnums`, and that `m` returns an instance of `String`. RDL supports many more complex type annotations; see below for a complete discussion and examples. We should emphasize here that RDL types are enforced as contracts at method entry and exit. There is no static checking that the method body conforms to the types.

The beta version of RDL also has an experimental mode in which method bodies can be *statically type checked* against their signatures. (This feature is only in the beta version of the RDL gem.) For example:

```ruby
file.rb:
  require 'rdl'

  type '(Fixnum) -> Fixnum', typecheck: :now
  def id(x)
    "forty-two"
  end
```

```
$ ruby file.rb
.../lib/rdl/typecheck.rb:32:in `error':  (RDL::Typecheck::StaticTypeError)
.../file.rb:5:5: error: got type `String' where return type `Fixnum' expected
.../file.rb:5:     "forty-two"
.../file.rb:5:     ^~~~~~~~~~~
```

Passing `typecheck: :now` to `type` checks the method body immediately or as soon as it is defined. Passing `typecheck: :call` to `type` statically type checks the method body whenever it is called. Passing `typecheck: sym` for some other symbol statically type checks the method body when `rdl_do_typecheck sym` is called.

RDL contracts and types are stored in memory at run time, so it's also possible for programs to query them. RDL includes lots of contracts and types for the core and standard libraries. Since those methods are generally trustworthy, RDL doesn't actually enforce the contracts (since that would add overhead), but they are available to search and query. RDL includes a small script `rdl_query` to look up type information from the command line. Note you might need to put the argument in quotes depending on your shell.

```shell
$ rdl_query String#include?            # print type for instance method of another class
$ rdl_query Pathname.glob              # print type for singleton method of a class
$ rdl_query Array                      # print types for all methods of a class
$ rdl_query "(Fixnum) -> Fixnum"       # print all methods that take a Fixnum and return a Fixnum
$ rdl_query "(.) -> Fixnum"            # print all methods that take a single arg of any type
$ rdl_query "(..., Fixnum, ...) -> ."  # print all methods that take a Fixnum as some argument

```

See below for more details of the query format. The `rdl_query` method performs the same function as long as the gem is loaded, so you can use this in `irb`.

```ruby
$ irb
> require 'rdl'
 => true
> require 'rdl_types'
 => true

> rdl_query '...' # as above
```

Currently only type information is returned by `rdl_query` (and not other pre or postconditions).

# Using RDL

## Supported versions of Ruby

RDL currently supports Ruby 2.x. It may or may not work with other versions.

## Installing RDL

`gem install rdl` should do it.

## Loading RDL

Use `require 'rdl'` to load the RDL library. If you want to use the core and standard library type signatures that come with RDL, follow it with `require 'rdl_types'`.  This will load the types based on the current `RUBY_VERSION`. Currently RDL has types for the following versions of Ruby:

* 2.x

(Currently all these are assumed to have the same library type signatures, which may not be correct.)

## Disabling RDL

*[github head only]*
For performance reasons you probably don't want to use RDL in production code. To disable RDL, replace `require 'rdl'` with `require 'rdl_disable'`. This will cause all invocations of RDL methods to either be no-ops or to do the minimum necessary to preserve the program's semantics (e.g., if the RDL method returns `self`, then so does the `rdl_disable` method.)

## Rails

*[github head only]*

To add types to Ruby on Rails, use `require 'rdl_rails'` instead. In development and test mode, this call will load `rdl`, `rdl_types`, and will load extra type annotations for Rails. In production mode, this call will load `rdl_disable`.

Place the `require` call in `application.rb` after the `Bundler.require` call. (This placement is needed so the Rails version string is available and the Rails environment is loaded):

Currently RDL has types for the following versions of Rails:

* Rails 5.x support - limited to the following:
  * Automatically generates
    * Models
      * Type annotations for model column getters and setters
      * find_by and find_by!

## Preconditions and Postconditions

The `pre` method takes a block and adds that block as a precondition to a method. When it's time to check the precondition, the block will be called with the method's arguments. If the block returns `false` or `nil` the precondition is considered to have failed, and RDL will raise a `ContractError`. Otherwise, if the block returns a true value, then the method executes as usual. The block can also raise its own error if the contract fails.

The `pre` method can be called in several ways:

* `pre { block }` - Apply precondition to the next method to be defined
* `pre(mth) { block }` - Apply precondition to method `mth` of the current class, where `mth` is a `Symbol` or `String`
* `pre(cls, mth) { block }` - Apply precondition to method `mth` of class `cls`, where `cls` is a `Class`, `Symbol`, or `String`, and `mth` is a `Symbol` or `String`

The `post` method is similar, except its block is called with the return value of the method (in the first position) followed by all the method's arguments. For example, you probably noticed that for `sqrt` above the `post` block took the return value `r` and the method argument `x`.

(Note: RDL does *not* clone or dup the arguments at method entry. So, for example, if the method body has mutated fields stored inside those argument objects, the `post` block or any other check evaluated afterwards will see the mutated field values rather than the original values.)

The `post` method can be called in the same ways as `pre`.

Methods can have no contracts, `pre` by itself, `post` by itself, both, or multiple instances of either. If there are multiple contracts, RDL checks that *all* contracts are satisfied, in the order that the contracts were bound to the method.

## Type Annotations

The `type` method adds a type contract to a method. It supports the same calling patterns as `pre` and `post`, except rather than a block, it takes a string argument describing the type. More specifically, `type` can be called as:

* `type 'typ'`
* `type m, 'typ'`
* `type cls, mth, 'typ'`

A type string generally has the form `(typ1, ..., typn) -> typ` indicating a method that takes `n` arguments of types `typ1` through `typn` and returns type `typ`. Below, to illustrate the various types RDL supports, we'll use examples from the core library type annotations.

The `type` method can be called with `wrap: false` so the type information is stored but the type is not enforced. For example, due to the way RDL is implemented, the method `String#=~` can't have a type or contract on it because then it won't set the correct `$1` etc variables:

```ruby
type :=~, '(Object) -> Fixnum or nil', wrap: false # Wrapping this messes up $1 etc
```

For consistency, `pre` and `post` can also be called with `wrap: false`, but this is generally not as useful.

# RDL Types

## Nominal Types

A nominal type is simply a class name, and it matches any object of that class or any subclass.

```ruby
type String, :insert, '(Fixnum, String) -> String'
```

## Nil Type

The nominal type `NilClass` can also be written as `nil`. The only object of this type is `nil`:

```ruby
type IO, :close, '() -> nil' # IO#close always returns nil
```

Currently, `nil` is treated as if it were an instance of any class.
```ruby
x = "foo"
x.insert(0, nil) # RDL does not report a type error
```
We chose this design based on prior experience with static type systems for Ruby, where not allowing this leads to a lot of false positive errors from the type system. However, we may change this in the future.

## Top Type (%any)

RDL includes a special "top" type `%any` that matches any object:
```ruby
type Object, :=~, '(%any) -> nil'
```
We call this the "top" type because it is the top of the subclassing hierarchy RDL uses. Note that `%any` is more general than `Object`, because not all classes inherit from `Object`, e.g., `BasicObject` does not.

## Union Types

Many Ruby methods can take several different types of arguments or return different types of results. The union operator `or` can be used to indicate a position where multiple types are possible.

```ruby
type IO, :putc, '(Numeric or String) -> %any'
type String, :getbyte, '(Fixnum) -> Fixnum or nil'
```

Note that for `getbyte`, we could leave off the `nil`, but we include it to match the current documentation of this method.

## Intersection Types

Sometimes Ruby methods have several different type signatures. (In Java these would be called *overloaded* methods.) In RDL, such methods are assigned a set of type signatures:

```ruby
type String, :[], '(Fixnum) -> String or nil'
type String, :[], '(Fixnum, Fixnum) -> String or nil'
type String, :[], '(Range or Regexp) -> String or nil'
type String, :[], '(Regexp, Fixnum) -> String or nil'
type String, :[], '(Regexp, String) -> String or nil'
type String, :[], '(String) -> String or nil'
```

We say the method's type is the *intersection* of the types above.

When this method is called at run time, RDL checks that at least one type signature matches the call:

```ruby
"foo"[0]  # matches first type
"foo"[0,2] # matches second type
"foo"[0..2] # matches third type
"foo"[0, "bar"] # error, doesn't match any type
# etc
```

Notice that union types in arguments could also be written as intersection types of methods, e.g., instead of the third type of `[]` above we could have equivalently written

```ruby
type String, :[], '(Range) -> String or nil'
type String, :[], '(Regexp) -> String or nil'
```

## Optional Argument Types

Optional arguments are denoted in RDL by putting `?` in front of the argument's type. For example:

```ruby
type String, :chomp, '(?String) -> String'
```

This is actually just a shorthand for an equivalent intersection type:

```ruby
type String, :chomp, '() -> String'
type String, :chomp, '(String) -> String'
```

but it helps make types more readable.

Like Ruby, RDL allows optional arguments to appear anywhere in a method's type signature.

## Variable Length Argument Types

In RDL, `*` is used to decorate an argument that may appear zero or more times. Currently in RDL this annotation may only appear on the rightmost argument. For example, `String#delete` takes one or more `String` arguments:

```ruby
type String, :delete, '(String, *String) -> String'
```

## Named Argument Types

RDL allows arguments to be named, for documentation purposes. Names are given after the argument's type, and they do not affect type contract checking in any way. For example:

```ruby
type Fixnum, :to_s, '(?Fixnum base) -> String'
```

Here we've named the first argument of `to_s` as `base` to give some extra hint as to its meaning.

## Dependent Types

RDL allows for refinement predicates to be attached to named arguments. These predicates are then checked when the method is called and returns. For instance:

```ruby
type '(Float x {{ x>=0 }}) -> Float y {{ y>=0 }}'
def sqrt(x)
    # return the square root of x
end
```

Here, RDL will check that the `sqrt` method is called on an argument of type `Float` which is greater than or equal to 0, and it will check the same of the return value of the method. Note that, in effect, dependent type contracts can be used in place of pre and post contracts.

Dependencies can also exist across a method's arguments and return value:

```ruby
type '(Fixnum x {{ x>y }}, Fixnum y) -> Float z {{ z==(x+y) }}'
def m(x,y) ... end
```

Any arbitrary code can be placed between the double braces of a type refinement, and RDL will dynamically check that this predicate evaluates to true, or raise a type error if it evaluates to false.

## Higher-order Types

RDL supports types for arguments or return values which are themselves `Proc` objects. Simply enclose the corresponding argument's type with braces to denote that it is a `Proc`. For example:

```ruby
type '(Fixnum, {(Fixnum) -> Fixnum}) -> Fixnum'
def m(x, y) ... end
```

The type annotation above states that the method m takes two arguments: one of type `Fixnum`, and another which is a `Proc` which itself takes a `Fixnum` and returns a `Fixnum`. A `Proc` may be the return value of a method as well:

```ruby
type '(Fixnum) -> {(Float) -> Float}'
def m(x) ... end
```

These higher-order types are checked by wrapping the corresponding `Proc` argument/return in a new `Proc` which checks that the type contract holds.

A type contract can be provided for a method block as well. The block's type should be included after the method argument types:

```ruby
type '(Fixnum, Float) {(Fixnum, String) -> String } -> Float'
def m(x,y,&blk) ... end
```

Note that this notation will work whether or not a method block is explicitly referenced in the parameters, i.e., whether or not `&blk` is included above. Finally, dependent types work across higher order contracts:

```ruby
type '(Fixnum x, Float y) -> {(Fixnum z {{ z>y }}) -> Fixnum}'
def m(x,y,&blk) ... end
```

The type contract above states that method `m` returns a `Proc` which takes a `Fixnum z` which must be greater than the argument `Float y`. Whenever this `Proc` is called, it will be checked that this contract holds.

## Class/Singleton Method Types

RDL method signatures can be used both for instance methods and for class methods (often called *singleton methods* in Ruby). To indicate a type signature applies to a singleton method, prefix the method name with `self.`:

```ruby
type File, 'self.dirname', '(String file) -> String dir'
```

(Notice also the use of a named return type, which we haven't seen before.)

Type signatures can be added to `initialize` by giving a type signature for `self.new`:

```ruby
type File, 'self.new', '(String file, ?String mode, ?String perm, ?Fixnum opt) -> File'
```

## Structural Types

Some Ruby methods are intended to take any object that has certain methods. RDL uses *structural types* to denote such cases:

```ruby
type IO, :puts, '(*[to_s: () -> String]) -> nil'
```

Here `IO#puts` can take zero or more arguments, all of which must have a `to_s` method that takes no arguments and returns a `String`.

The actual checking that RDL does here varies depending on what type information is available. Suppose we call `puts(o)`. If `o` is an instance of a class that has a type signature `t` for `to_s`, then RDL will check that `t` is compatible with `() -> String`. On the other hand, if `o` is an instance of a class with no type signature for `to_s`, RDL only checks that `o` has a `to_s` method, but it doesn't check its argument or return types.

## Singleton Types

Not to be confused with types for singleton methods, RDL includes *singleton types* that denote positions that always have one particular value; this typically happens only in return positions. For example, `Dir#mkdir` always returns the value 0:

```ruby
type Dir, 'self.mkdir', '(String, ?Fixnum) -> 0'
```

In RDL, any integer or floating point number denotes a singleton type. Arbitrary values can be turned into singleton types by wrapping them in `${.}`. For example, `Float#angle` always returns 0 or pi.

```ruby
type Float, :angle, '() -> 0 or ${Math::PI}'
```

RDL checks if a value matches a singleton type using `equal?`. As a consequence, singleton string types aren't currently possible.

Note that the type `nil` is actually implemented as a singleton type with the special behavior that `nil` is a treated as a member of any class. However, while `nil` can in general be used anywhere any type is expected, it *cannot* be used where a different singleton type is expected. For example, `nil` could not be a return value of `Dir#mkdir` or `Float#angle`.

## Self Type

Consider a method that returns `self`:

```ruby
class A
  def id
    self
  end
end
```

If that method might be inherited, we can't just give it a nominal type, because it will return a different object type in a subclass:

```ruby
class B < A
end

type A, :id, '() -> A'
A.new.id # okay, returns an A
B.new.id # type error, returns a B
```

To solve this problem, RDL includes a special type `self` for this situation:

```ruby
type A, :id, '() -> self'
A.new.id # okay, returns self
B.new.id # also okay, returns self
```

Thus, the type `self` means "any object of self's class."

## Type Aliases

RDL allows types to be aliases to make them faster to write down and more readable. All type aliases begin with `%`. RDL has one built-in alias, `%bool`, which is shorthand for `TrueClass or FalseClass`:

```ruby
type String, :==, '(%any) -> %bool'
```

Note it is not a bug that `==` is typed to allow any object. Though you would think that developers would generally only compare objects of the same class (since otherwise `==` almost always returns false), in practice a lot of code does compare objects of different classes.

Method `type_alias(name, typ)` can be used to create a user-defined type alias, where `name` must begin with `%`:

```ruby
type_alias '%real', 'Integer or Float or Rational'
type_alias '%string', '[to_str: () -> String]'
type_alias '%path', '%string or Pathname'
```

Type aliases have to be created before they are used (so above, `%path` must be defined after `%string`).

## Generic Class Types

RDL supports *parametric polymorphism* for classes, a.k.a. *generics*. The `type_params` method names the type parameters of the class, and those parameters can then be used inside type signatures:

```ruby
class Array
  type_params [:t], :all?

  type :shift, '() -> t'
end
```

Here the first argument to `type_params` is a list of symbols or strings that name the type parameters. In this case there is one parameter, `t`, and it is the return type of `shift`.

Generic types are applied to type arguments using `<...>` notation, e.g., `Array<Fixnum>` is an `Array` class where `t` is replaced by `Fixnum`. Thus, for example, if `o` is an `Array<Fixnum>`, then `o.shift` returns `Fixnum`. As another example, here is the type for the `[]` method of `Array`:

```ruby
type Array, :[], '(Range) -> Array<t>'
type Array, :[], '(Fixnum or Float) -> t'
type Array, :[], '(Fixnum, Fixnum) -> Array<t>'
```

Thus if `o` is again an `Array<Fixnum>`, then `o[0]` returns a `Fixnum` and `o[0..5]` returns an `Array<Fixnum>`.

In general it's impossible to assign generic types to objects without knowing the programmer's intention. For example, consider code as simple as `x = [1,2]`. Is it the programmer's intention that `x` is an `Array<Fixnum>`? `Array<Numeric>`? `Array<Object>`?

Thus, by default, even though `Array` is declared to take type parameters, by default RDL treats array objects at the *raw* type `Array`, which means the type parameters are ignored whenever they appear in types. For our example, this means a call such as `x.push("three")` would not be reported as an error (the type signature of `Array#push` is `'(?t) -> Array<t>'`).

To fully enforce generic types, RDL requires that the developer `instantiate!` an object with the desired type parameters:

```ruby
x = [1,2]
x.instantiate!('Fixnum')
x.push("three") # type error
```

Note that the instantiated type is associated with the object, not the variable:
```ruby
y = x
y.push("three") # also a type error
```

When RDL instantiates an object with type parameters, it needs to ensure the object's contents are consistent with the type. Currently this is enforced using the second parameter to `type_params`, which must name a method that behaves like `Array#all?`, i.e., it iterates through the contents, checking that a block argument is satisfied. As seen above, for `Array` we call `type_params(:t, :all?)`. Then at the call `x.instantiate('Fixnum')`, RDL will call `Array#all?` to iterate through the contents of `x` to check they have type `Fixnum`.

RDL also includes a `deinstantiate!` method to remove the type instantiation from an object:
```ruby
x.deinstantiate!
x.push("three") # no longer a type error
```

Finally, `type_params` can optionally take a third argument that is an array of *variances*, which are either `:+` for covariance, `:-` for contravariance, or `:~` for invariance. If variances aren't listed, type parameters are assumed to be invariant, which is a safe default.

Variances are only used when RDL checks that one type is a subtype of another. This only happens in limited circumstances, e.g., arrays of arrays where all levels have instantiated types. So generally you don't need to worry much about the variance.

The rules for variances are standard. Let's assume `A` is a subclass of `B`. Also assume there is a class `C` that has one type parameter. Then:
* `C<A>` is a subtype of `C<A>` always
* `C<A>` is a subtype of `C<B>` if `C`'s type parameter is covariant
* `C<B>` is a subtype of `C<A>` if `C`'s type parameter is contravariant

## Tuple Types

A type such as `Array<Fixnum>` is useful for homogeneous arrays, where all elements have the same type. But Ruby programs often use heterogenous arrays, e.g., `[1, "two"]`. The best generic type we can give this is `Array<Fixnum or String>`, but that's imprecise.

RDL includes special *tuple types* to handle this situation. Tuple types are written `[t1, ..., tn]`, denoting an `Array` of `n` elements of types `t1` through `tn`, in that order. For example, `[1, "two"]` has type `[Fixnum, String]`. As another example, here is the type of `Process#getrlimit`, which returns a two-element array of `Fixnums`:

```ruby
type Process, 'self.getrlimit', '(Symbol or String or Fixnum resource) -> [Fixnum, Fixnum] cur_max_limit'
```

## Finite Hash Types

Similarly to tuple types, RDL also supports *finite hash types* for heterogenous hashes. Finite hash types are written `{k1 => v1, ..., kn => vn}` to indicate a `Hash` with `n` mappings of type `ki` maps to `vi`. The `ki` may be strings, integers, floats, or constants denoted with `${.}`. If a key is a symbol, then the mapping should be written `ki: vi`. In the latter case, the `{}`'s can be left off:
```ruby
type MyClass, :foo, '(a: Fixnum, b: String) { () -> %any } -> %any'
```
Here `foo`, takes a hash where key `:a` is mapped to a `Fixnum` and key `:b` is mapped to a `String`. Similarly, `{'a'=>Fixnum, 2=>String}` types a hash where keys `'a'` and `2` are mapped to a `Fixnum` and `String`, respectively. Both syntaxes can be used to define hash types.

## Type Casts

Sometimes RDL does not have precise information about an object's type (this is most useful during static type checking). For these cases, RDL supports type casts of the form `o.type_cast(t)`. This call returns a new object that delegates all methods to `o` but that will be treated by RDL as if it had type `t`. If `force: true` is passed to `type_cast`, RDL will perform the cast without checking whether `o` is actually a member of the given type. For example, `x = "a".type_cast('nil', force: true)` will make RDL treat `x` as if it had type `nil`, even though it's a `String`.

## Bottom Type (%bot)

RDL also includes a special *bottom* type `%bot` that is a subtype of any type, including any class and any singleton types. In static type checking, the type `%bot` is given to so-called *void value expressions*, which are `return`, `break`, `next`, `redo`, and `retry` (notice that these expressions perform jumps rather than producing a value, hence they can be treated as having an arbitrary type). No Ruby objects have type `%bot`.

## Non-null Type

*[github head only]*

Types can be prefixed with `!` to indicate the associated value is not `nil`. For example:

`type :x=, '(!Fixnum) -> !Fixnum'  # x's argument must not be nil`

**Warning:** This is simply *documentation* of non-nullness, and **is not checked** by the static type checker. The contract checker might or might not enforce non-nullness. (For those who are curious: RDL has this annotation because it seems useful for descriptive purposes. However, it's quite challenging to build a practical analysis that enforces non-nilness without reporting too many false positives.)

# Static Type Checking

RDL has experimental support (note: this is in beta release) for static type checking. As mentioned in the introduction, calling `type` with `typecheck: :now` statically type checks the body of the annotated method body against the given signature. If the method has already been defined, RDL will try to check the method immediately. Otherwise, RDL will statically type check the method as soon as it is loaded.

Often method bodies cannot be type checked as soon as they are loaded because they refer to classes, methods, and variables that have not been created yet. To support these cases, some other symbol can be supplied as `typecheck: sym`. Then when `rdl_do_typecheck sym` is called, all methods typechecked at `sym` will be statically checked.

Additionally, `type` can be called with `typecheck: :call`, which will delay checking the method's type until the method is called. Currently these checks are not cached, so expect a big performance hit for using this feature.

To perform type checking, RDL needs source code, which it gets by parsing the file containing the to-be-typechecked method. Hence, static type checking does not work in `irb` since RDL has no way of getting the source.

*[github head only]* Typechecking does work in `pry` (this feature has only limited testing) as long as typechecking is delayed until after the method is defined:

```ruby
[2] pry(main)> require 'rdl'
[3] pry(main)> require 'rdl_types'
[4] pry(main)> type '() -> Fixnum', typecheck: :later    # note: typecheck: :now doesn't work in pry
[5] pry(main)> def f
[5] pry(main)*   'haha'  
[5] pry(main)* end  
[6] pry(main)> rdl_do_typecheck :later
RDL::Typecheck::StaticTypeError:
(string):2:3: error: got type `String' where return type `Fixnum' expected
(string):2:   'haha'
(string):2:   ^~~~~~
from .../typecheck.rb:158:in `error'
```

RDL currently uses the [parser Gem](https://github.com/whitequark/parser) to parse Ruby source code. (And RDL uses the parser gem's amazing diagnostic output facility to print type error messages.)

Next we discuss some special features of RDL's type system and some of its limitations.

## Types for Variables

In a standard type system, local variables have one type throughout a method or function body. For example, in C and Java, declaring `int x` means `x` can only be used as an integer. However, in Ruby, variables need not be declared before they are used. Thus, by default, RDL treats local variables *flow-sensitively*, meaning at each assignment to a local variable, the variable's type is replaced by the type of the right hand side. For example:

```ruby
x = 3       # Here `x` is a `Fixnum`
x = "three" # Now `x` is a `String`
```
(Note this is a slight fib, since after the first line, `x` will actually have the singleton type `3`. But we'll ignore this just to keep the discussion a bit simpler, especially since `3` is a subtype of `Fixnum`.)

After conditionals, variables have the union of the types they have along both branches:

```ruby
if (some condition) then x = 3 else x = "three" end
# x has type `Fixnum or String`
```

RDL also provides a method `var_type` that can be used to force a local variable to have a single type through a method body, i.e., to treat it *flow-insensitively* like a standard type system:

```ruby
var_type :x, 'Fixnum'
x = 3       # okay
x = "three" # type error
```

The first argument to `var_type` is a symbol with the local variable name, and the second argument is a string containing the variable's type. Note that `var_type` is most useful at the beginning of method or code block. Using it elsewhere may result in surprising error messages, since RDL requires variables with fixed types to have the same type along all paths. Method parameters are treated as if `var_type` was called on them at the beginning of the method, fixing them to their declared type. This design choice may be revisited in the future.

*[github head only]*
There is one subtlety for local variables and code blocks. Consider the following code:
```ruby
x = 1
m() { x = 'bar' }
# what is x's type here?
```
If `m` invokes the code block, `x` will be a `String` after the call. Otherwise `x` will be `1`. Since RDL can't tell whether the code block is ever called, it assigns `x` type `1 or String`. It's actually quite tricky to do very precise reasoning about code blocks. For example, `m` could (pathologically) store its block in a global variable and then only call it the second time `m` is invoked. To keep its reasoning simple, RDL treats any local variables captured (i.e., imported from an outer scope) by a code block flow-insensitively for the lifetime of the method. The type of any such local variables is the union of all types that are ever assigned to it.

RDL always treats instance, class, and global variables flow-insensitively, hence their types must be defined with `var_type`:

```ruby
class A
  var_type :@f, 'Fixnum'
  def m
    @f = 3       # type safe
    @f = "three" # type error, incompatible type in assignment
    @g = 42      # type error, no var_type for @g
  end
end
```

The `var_type` method may also be called as `var_type klass, :name, typ` to assign a type to an instance or class variable of class `klass`.

As a short-hand, RDL defines methods `attr_accessor_type`, `attr_reader_type`, and `attr_writer_type` to behave like their corresponding non-`_type` analogs but  attribute types follow the attribute names. For example, `attr_accessor_type :f, 'Fixnum', :g, 'String'` is equivalent to:

```ruby
var_type :@f, 'Fixnum'
var_type :@g, 'String'
type :f, '() -> Fixnum'
type :f=, '(Fixnum) -> Fixnum'
type :g, '() -> String'
type :g=, '(String) -> String'
```

## Tuples, Finite Hashes, and Subtyping

When RDL encounters a literal array in the program, it assigns it a tuple type, which allows, among other things, precise handling of multiple assignment. For example:

```ruby
x = [1, 'foo']  # x has type [1, String]
a, b = x        # a has type 1, b has type String  
```

RDL also allows a tuple `[t1, ..., tn]` to be used where `Array<t1 or ... or tn>` is expected. This means both when a tuple is passed to an `Array` position, and when any method is invoked on the tuple (even if RDL could safely apply that method to the tuple; this may change in the future):

```ruby
var_type @f, 'Array<Fixnum or String>'
@f = [1, 'foo'] # okay
@f.length       # also okay
```

To maintain soundness, a tuple that is used as an `Array` is treated as if it were always an array. For example:

```ruby
x = [1, 'foo']  # at this point, x has type [1, String]
var_type @f, '[1, String]'
@f = x          # okay so far
var_type @g, 'Array<Fixnum or String>'
@g = x          # uh oh
```

When RDL encounters the assignment to `@g`, it retroactively changes `x` to have type `Array<Fixnum or String>`, which is incompatible with type `[1, String]`, so the last assignment signals an error.

RDL uses the same approach for hashes: hash literals are treated as finite hashes. A finite hash `{k1=>v1, ..., kn=>vn}` can be used where `Hash<k1 or ... or kn, v1 or ... or vn>` is expected. And if a finite hash is used as a `Hash` (including invoking methods on the finite hash; this may change in the future), then it is retroactively converted to a `Hash`.

## Other Features and Limitations

* *[github head only]*
*Displaying types.* As an aid to debugging, the method `rdl_note_type e` will display the type of `e` during type checking. At run time, this method returns its argument. Note that in certain cases RDL may type check the same code repeatedly in which case an expression's type could be printed multiple times.

* *Conditional guards and singletons.* If an `if` or `unless` guard has a singleton type, RDL will typecheck both branches but not include types from the unrealizable branch in the expression type. For example, `if true then 1 else 'two' end` has type `1`. RDL behaves similarly for `&&` and `||`. However, RDL does not implement this logic for `case`.

* *Multiple Assignment and nil.* In Ruby, extra left-hand sides of multiple assignments are set to `nil`, e.g., `x, y = [1]` sets `x` to `1` and `y` to `nil`. However, RDL reports an error in this case; this may change in the future.

* *Block formal arguments.* Similarly, RDL reports an error if a block is called with the wrong number of arguments even though Ruby does not signal an error in this case.

* *Caching.* If `typecheck: :call` is specified on a method, Ruby will type check the method every time it is called. In the future, RDL will cache these checks.

* *Unsupported Features.* There are several features of Ruby that are currently not handled by RDL. Here is a non-exhaustive list:
  * `super` is not supported.
  * `lambda` has special semantics for `return`; this is not supported.
  * Only simple block argument lists and `for` iteration variables are supported.
  * Control flow for exceptions is not analyzed fully soundly; some things are not reported as possibly `nil` that could be.
  * Only simple usage of constants is handled.

## Assumptions

RDL makes some assumptions that should hold unless your Ruby code is doing something highly unusual:

* `Class#===` is not redefined

(More assumptions will be added here as they are added to RDL...)

# Other RDL Methods

RDL also includes a few other useful methods:

* `rdl_alias new_name, old_name` tells RDL that method `new_name` is an alias for method `old_name`, and therefore they should have the same contracts and types. This method is only needed when adding contracts and types to method that have already been aliased; it's not needed if the method is aliased after the contract or type has been added.

* `rdl_nowrap`, if called at the top-level of a class, causes RDL to behave as if `wrap: false` were passed to all `type`, `pre`, and `post` calls in the class. This is mostly used for the core and standard libraries, which have trustworthy behavior hence enforcing their types and contracts is not worth the overhead.

* `rdl_query` prints information about types; see below for details.

# Queries

As discussed above, RDL includes a small script, `rdl_query`, to look up type information. (Currently it does not support other pre- and postconditions.) The script takes a single argument, which should be a string. Note that when using the shell script, you may need to use quotes depending on your shell. Currently several queries are supported:

* Instance methods can be looked up as `Class#method`.

```shell
$ rdl_query String#include?
String#include?: (String) -> TrueClass or FalseClass
```

* Singleton (class) methods can be looked up as `Class.method`.

```shell
$ rdl_query Pathname.glob
Pathname.glob: (String p1, ?String p2) -> Array<Pathname>
```

* All methods of a class can be listed by passing the class name `Class`.

```shell
$ rdl_query Array
&: (Array<u>) -> Array<t>
*: (String) -> String
... and a lot more
```

* Methods can also be search for by their type signature:

```shell
$ rdl_query "(Fixnum) -> Fixnum"      # print all methods of type (Fixnum) -> Fixnum
BigDecimal.limit: (Fixnum) -> Fixnum
Dir#pos=: (Fixnum) -> Fixnum
... and a lot more
```

The type signature uses the standard RDL syntax, with two extensions: `.` can be used as a wildcard to match any type, and `...` can be used to match any sequence of arguments.

```shell
$ rdl_query "(.) -> ."                 # methods that take one argument and return anything
$ rdl_query "(Fixnum, .) -> ."         # methods that take two arguments, the first of which is a Fixnum
$ rdl_query "(Fixnum, ...) -> ."       # methods whose first argument is a Fixnum
$ rdl_query "(..., Fixnum) -> ."       # methods whose last argument is a Fixnum
$ rdl_query "(..., Fixnum, ...) -> ."  # methods that take a Fixnum somewhere
$ rdl_query "(Fixnum or .) -> ."       # methods that take a single argument that is a union containing a Fixnum
$ rdl_query "(.?) -> ."                # methods that take one, optional argument
```

Note that aside from `.` and `...`, the matching is exact. For example `(Fixnum) -> Fixnum` will not match a method of type `(Fixnum or String) -> Fixnum`.

# Configuration

To configure RDL, execute the following shortly after RDL is loaded:

```ruby
RDL.config { |config|
  # use config to configure RDL here
}
```

RDL supports the following configuration options:

* `config.nowrap` - `Array<Class>` containing all classes whose methods should not be wrapped.
* `config.gather_stats` - currently disabled.
* `config.report` - if true, then when the program exits, RDL will print out a list of methods that were statically type checked, and methods that were annotated to be statically type checked but weren't.
* `config.guess_types` - *[github head only]* List of classes (of type `Array<Symbol>`). For every method added to a listed class *after* this configuration option is set, RDL will record the types of its arguments and returns at run-time. Then when the program exits, RDL will print out a skeleton for each class with types for the monitored methods based on what RDL recorded at run-time and based on what Ruby knows about the methods' signatures. This is probably not going to produce the correct method types, but it might be a good starting place.
* `config.type_defaults` - *[github head only]* Hash containing default options for `type`. Initially `{ wrap: true, typecheck: false }`.
* `config.pre_defaults` - *[github head only]* Hash containing default options for `pre`. Initially `{ wrap: true }`.
* `config.post_defaults` - same as `pre_defaults`, but for `post`.

# Bibliography

Here are some research papers we have written exploring contracts, types, and Ruby.

* Brianna M. Ren and Jeffrey S. Foster.
[Just-in-Time Static Type Checking for Dynamic Languages](http://www.cs.umd.edu/~jfoster/papers/pldi16.pdf).
In ACM SIGPLAN Conference on Programming Language Design and Implementation (PLDI), Santa Barbara, CA, June 2016.

* T. Stephen Strickland, Brianna Ren, and Jeffrey S. Foster.
[Contracts for Domain-Specific Languages in Ruby](http://www.cs.umd.edu/~jfoster/papers/dls12.pdf).
In Dynamic Languages Symposium (DLS), Portland, OR, October 2014.

* Brianna M. Ren, John Toman, T. Stephen Strickland, and Jeffrey S. Foster.
[The Ruby Type Checker](http://www.cs.umd.edu/~jfoster/papers/oops13.pdf).
In Object-Oriented Program Languages and Systems (OOPS) Track at ACM Symposium on Applied Computing, pages 1565–1572, Coimbra, Portugal, March 2013.

* Jong-hoon (David) An, Avik Chaudhuri, Jeffrey S. Foster, and Michael Hicks.
[Dynamic Inference of Static Types for Ruby](http://www.cs.umd.edu/~jfoster/papers/popl11.pdf).
In ACM SIGPLAN-SIGACT Symposium on Principles of Programming Languages (POPL), pages 459–472, Austin, TX, USA, January 2011.

* Jong-hoon (David) An.
[Dynamic Inference of Static Types for Ruby](http://www.cs.umd.edu/~jfoster/papers/thesis-an.pdf).
MS thesis, University of Maryland, College Park, 2010.

* Michael Furr.
[Combining Static and Dynamic Typing in Ruby](https://www.cs.umd.edu/~jfoster/papers/thesis-furr.pdf).
PhD thesis, University of Maryland, College Park, 2009.

* Michael Furr, Jong-hoon (David) An, Jeffrey S. Foster, and Michael Hicks.
[The Ruby Intermediate Language](http://www.cs.umd.edu/~jfoster/papers/dls09-ril.pdf).
In Dynamic Languages Symposium (DLS), pages 89–98, Orlando, Florida, October 2009.

* Michael Furr, Jong-hoon (David) An, and Jeffrey S. Foster.
[Profile-Guided Static Typing for Dynamic Scripting Languages](http://www.cs.umd.edu/~jfoster/papers/oopsla09.pdf).
In ACM SIGPLAN International Conference on Object-Oriented Programming, Systems, Languages and Applications (OOPSLA), pages 283–300, Orlando, Floria, October 2009. Best student paper award.

* Michael Furr, Jong-hoon (David) An, Jeffrey S. Foster, and Michael Hicks.
[Static Type Inference for Ruby](http://www.cs.umd.edu/~jfoster/papers/oops09.pdf).
In Object-Oriented Program Languages and Systems (OOPS) Track at ACM Symposium on Applied Computing (SAC), pages 1859–1866, Honolulu, Hawaii, March 2009.

# Copyright

Copyright (c) 2014-2016, University of Maryland, College Park. All rights reserved.

# Contributors

## Authors

* [Jeffrey S. Foster](http://www.cs.umd.edu/~jfoster/)
* [Brianna M. Ren](https://www.cs.umd.edu/~bren/)
* [T. Stephen Strickland](https://www.cs.umd.edu/~sstrickl/)
* Alexander T. Yu
* Milod Kazerounian

# TODO List

* How to check whether initialize? is user-defined? method_defined? always
  returns true, meaning wrapping isn't fully working with initialize.

* Currently if a NominalType name is expressed differently, e.g., A
  vs. EnclosingClass::A, the types will be different when compared
  with ==.

* Macros, %bool should really be %any

* Method types that are parametric themselves (not just ones that use
  enclosing class parameters)

* Rails types

* Deferred contracts on new (watch for class addition)

* DSL contracts

* double-splat arguments, which bind to an arbitrary set of keywords

* included versus extended modules, e.g., Kernel is included in Object, so its
  class methods become Object's instance methods

* Better story for different types for different Ruby versions

* Better query facility (more kinds of searches). Contract queries?

* Write documentation on: Raw Contracts and Types, RDL Configuration, Code Overview

* Structural type queries, allow name to be unknown; same with finite hash keys,
  same with generic base types?

* Allow ... in named args list in queries

* Queries, include more regexp operators aside from . and ...

* Queries, allow regexp in class and method names; suggested by Andreas Adamcik, Vienna

* Tag for private methods
