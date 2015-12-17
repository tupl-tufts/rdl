# Introduction

RDL is a lightweight system for adding contracts to Ruby. A *contract* decorates a method with assertions describing what the method assumes about its inputs (called a *precondition*) and what the method guarantees about its outputs (called a *postcondition*). For example, using RDL we can write

```
require 'rdl'

pre { |x| x > 0 }
post { |r,x| r > 0 }
def sqrt(x)
  # return the square root of x
end
```

Given this program, RDL intercepts the call to `sqrt` and passes its argument to the `pre` block, which checks that the arugment is positive. Then when `sqrt` returns, RDL passes the return value (as `r`) and the initial argument (as `x`) to the `post` block, which checks that the return is positive. (Let's ignore complex numbers to keep things simple...)


RDL contracts are enforced at method entry and exit. For example, if we call `sqrt(49)`, RDL first checks that `49 > 0`; then it passes `49` to `sqrt`, which (presumably) returns `7`; then RDL checks that `7 > 0`; and finally it returns `7`.

In addition to arbitrary pre- and post-conditions, RDL also has extensive support for contracts that are *types*. For example, we can write the following in RDL:

```
require 'rdl'

type '(Fixnum, Fixnum) -> String'
def m(x,y) ... end
```

This indicates that `m` is that method that returns a `String` if given two `Fixnum` arguments. Again this contract is enforced at run-time: When `m` is called, RDL checks that `m` is given exactly two arguments and both are `Fixnums`, and that `m` returns an instance of `String`. RDL supports many more complex type annotations; see below for a complete discussion and examples. We should emphasize here that RDL types are enforced as contracts at method entry and exit. There is no static checking that the method body conforms to the types.

RDL contracts and types are stored in memory at run time, so it's also possible for programs to query them. RDL includes lots of contracts and types for the core and standard libraries. Since those methods are generally trustworthy, RDL doesn't actually enforce the contracts (since that would add overhead), but they are available to search and query. For example:

```
> require 'rdl'
 => true
> require 'rdl_types'
 => true

> rdl_query 'hash'             # get type for instance method of current class
Object#hash: () -> Fixnum
 => nil
> rdl_query 'String#include?'   # get type for instance method of another class
String#include?: (String) -> FalseClass or TrueClass
 => nil
 > rdl_query 'Pathname.glob'   # get type for singleton method of a class
 Pathname.glob: (String p1, ?String p2) -> Array<Pathname>
 => nil
```

Currently only type information is returned by `rdl_query` (and not other pre or postconditions).

# RDL Reference

## Supported versions of Ruby

RDL currently supports Ruby 2.2. It may or may not work with other versions.

## Installing RDL

`gem install rdl` should do it.

## Loading RDL

Use `require 'rdl'` to load the RDL library. If you want to use the core and standard library type signatures that come with RDL, follow it with `require 'rdl_types'`.  This will load the types based on the current `RUBY_VERSION`. Currently RDL has types for the following versions of Ruby:

* 2.x

(Currently all these are assume to have the same library type signatures, which may not be correct.)

If you're using Ruby on Rails, you can similarly `require 'rails_types'` to load in type annotations for the current `Rails::VERSION::STRING`. More specifically, add the following lines in `application.rb` after the `Bundler.require` call. (This placement is needed so the Rails version string is available and the Rails environment is loaded):

```
require 'rdl'
require 'rdl_types'
require 'rails_types'
```

Currently RDL has types for the following versions of Rails:

* Rails support is currently almost non-existent; more coming in the future

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

## Type Signatures

The `type` method adds a type contract to a method. It supports the same calling patterns as `pre` and `post`, except rather than a block, it takes a string argument describing the type. More specifically, `type` can be called as:

* `type 'typ'`
* `type m, 'typ'`
* `type cls, mth, 'typ'`

A type string generally has the form `(typ1, ..., typn) -> typ` indicating a method that takes `n` arguments of types `typ1` through `typn` and returns type `typ`. To illustrate the various types RDL supports, we'll use examples from the core library type annotations.

### Nominal Types

A nominal type is simply a class name, and it matches any object of that class or any subclass.

```
type String, :insert, '(Fixnum, String) -> String'
```

### Nil Type

The nominal type `NilClass` can also be written as `nil`. The only object of this type is `nil`:

```
type IO, :close, '() -> nil' # IO#close always returns nil
```

Currently, `nil` is treated as if it were an instance of any class.
```
x = "foo"
x.insert(0, nil) # RDL does not report a type error
```
We chose this design based on prior experience with static type systems for Ruby, where not allowing this leads to a lot of false positive errors from the type system. However, we may change this in the future.

### Top Type (%any)

RDL includes a special "top" type `%any` that matches any object:
```
type Object, :=~, '(%any) -> nil'
```
We call this the "top" type because it is the top of the subclassing hierarchy RDL uses. Note that `%any` is more general than `Object`, because not all classes inherit from `Object`, e.g., `BasicObject` does not.

### Union Types

Many Ruby methods can take several different types of arguments or return different types of results. The union operator `or` can be used to indicate a position where multiple types are possible.

```
type IO, :putc, '(Numeric or String) -> %any'
type String, :getbyte, '(Fixnum) -> Fixnum or nil'
```

Note that for `getbyte`, we could leave off the `nil`, but we include it to match the current documentation of this method.

### Intersection Types

Sometimes Ruby methods have several different type signatures. (In Java these would be called *overloaded* methods.) In RDL, such methods are assigned a set of type signatures:

```
type String, :[], '(Fixnum) -> String or nil'
type String, :[], '(Fixnum, Fixnum) -> String or nil'
type String, :[], '(Range or Regexp) -> String or nil'
type String, :[], '(Regexp, Fixnum) -> String or nil'
type String, :[], '(Regexp, String) -> String or nil'
type String, :[], '(String) -> String or nil'
```

We say the method's type is the *intersection* of the types above.

When this method is called at run time, RDL checks that at least one type signature matches the call:

```
"foo"[0]  # matches first type
"foo"[0,2] # matches second type
"foo"[0..2] # matches third type
"foo"[0, "bar"] # error, doesn't match any type
# etc
```

Notice that union types in arguments could also be written as intersection types of methods, e.g., instead of the third type of `[]` above we could have equivalently written

```
type String, :[], '(Range) -> String or nil'
type String, :[], '(Regexp) -> String or nil'
```

### Optional Argument Types

Optional arguments are denoted in RDL by putting `?` in front of the argument's type. For example:

```
type String, :chomp, '(?String) -> String'
```

This is actually just a shorthand for an equivalent intersection type:

```
type String, :chomp, '() -> String'
type String, :chomp, '(String) -> String'
```

but it helps make types more readable.

Like Ruby, RDL allows optional arguments to appear anywhere in a method's type signature.

### Variable Length Argument Types

In RDL, `*` is used to decorate an argument that may appear zero or more times. Currently in RDL this annotation may only appear on the rightmost argument. For example, `String#delete` takes one or more `String` arguments:

```
type String, :delete, '(String, *String) -> String'
```

### Named Argument Types

RDL allows arguments to be named, for documentation purposes. Names are given after the argument's type, and they do not affect type contract checking in any way. For example:

```
type Fixnum, :to_s, '(?Fixnum base) -> String'
```

Here we've named the first argument of `to_s` as `base` to give some extra hint as to its meaning.

### Block Types

Types signatures can include a type for a method's block argument:

```
type Pathname, :ascend, '() { (Pathname) -> %any } -> %any'
```

Here the block passed to `Pathname.ascend` must take a `Pathname` and can return any object.

This is a *higher-order* contract, because it applies to a higher-order method, i.e., a method that can take a block argument.

Currently higher-order contracts are not enforced. That is, RDL will not actually check contracts on block arguments.

### Class/Singleton Method Types

RDL method signatures can be used both for instance methods and for class methods (often called *singleton methods* in Ruby). To indicate a type signature applies to a singleton method, prefix the method name with `self.`:

```
type File, 'self.dirname', '(String file) -> String dir'
```

(Notice also the use of a named return type, which we haven't seen before.)

Type signatures can be added to `initialize` by giving a type signature for `self.new`:

```
type File, 'self.new', '(String file, ?String mode, ?String perm, ?Fixnum opt) -> File'
```

### Structural Types

Some Ruby methods are intended to take any object that has certain methods. RDL uses *structural types* to denote such cases:

```
type IO, :puts, '(*[to_s: () -> String]) -> nil'
```

Here `IO#puts` can take zero or more arguments, all of which must have a `to_s` method that takes no arguments and returns a `String`.

The actual checking that RDL does here varies depending on what type information is available. Suppose we call `puts(o)`. If `o` is an instance of a class that has a type signature `t` for `to_s`, then RDL will check that `t` is compatible with `() -> String`. On the other hand, if `o` is an instance of a class with no type signature for `to_s`, RDL only checks that `o` has a `to_s` method, but it doesn't check its argument or return types.

### Singleton Types

Not to be confused with types for singleton methods, RDL includes *singleton types* that denote positions that always have one particular value; this typically happens only in return positions. For example, `Dir#mkdir` always returns the value 0:

```
type Dir, 'self.mkdir', '(String, ?Fixnum) -> 0'
```

In RDL, any integer or floating point number denotes a singleton type. Arbitrary values can be turned into singleton types by wrapping them in `${.}`. For example, `Float#angle` always returns 0 or pi.

```
type Float, :angle, '() -> 0 or ${Math::PI}'
```

RDL checks if a value matches a singleton type using `equal?`. As a consequence, singleton string types aren't currently possible.

### Self Type

Consider a method that returns `self`:

```
class A
  def id
    self
  end
end
```

If that method might be inherited, we can't just give it a nominal type, because it will return a different object type in a subclass:

```
class B < A
end

type A, :id, '() -> A'
A.new.id # okay, returns an A
B.new.id # type error, returns a B
```

To solve this problem, RDL includes a special type `self` for this situation:

```
type A, :id, '() -> self'
A.new.id # okay, returns self
B.new.id # also okay, returns self
```

Note that type `self` means *exactly* the self object, i.e., it is a singleton type. It does not mean "any object of self's class." Thus, for example, `Object#clone` has type `() -> %any`, since it will return a different object. We might change this behavior in the future.

### Type Aliases

RDL allows types to be aliases to make them faster to write down and more readable. All type aliases begin with `%`. RDL has one built-in alias, `%bool`, which is shorthand for `TrueClass or FalseClass`:

```
type String, :==, '(%any) -> %bool'
```

Note it is not a bug that `==` is typed to allow any object. Though you would think that developers would generally only compare objects of the same class (since otherwise `==` almost always returns false), in practice a lot of code does compare objects of different classes.

Method `type_alias(name, typ)` can be used to create a user-defined type alias, where `name` must begin with `%`:

```
type_alias '%real', 'Integer or Float or Rational'
type_alias '%string', '[to_str: () -> String]'
type_alias '%path', '%string or Pathname'
```

Type aliases have to be created before they are used (so above, `%path` must be defined after `%string`).

### Generic Class Types

RDL supports *parametric polymorphism* for classes, a.k.a. *generics*. The `type_params` method names the type parameters of the class, and those parameters can then be used inside type signatures:

```
class Array
  type_params [:t], :all?

  type :shift, '() -> t'
end
```

Here the first argument to `type_params` is a list of symbols or strings that name the type parameters. In this case there is one parameter, `t`, and it is the return type of `shift`.

Generic types are applied to type arguments using `<...>` notation, e.g., `Array<Fixnum>` is an `Array` class where `t` is replaced by `Fixnum`. Thus, for example, if `o` is an `Array<Fixnum>`, then `o.shift` returns `Fixnum`. As another example, here is the type for the `[]` method of `Array`:

```
type Array, :[], '(Range) -> Array<t>'
type Array, :[], '(Fixnum or Float) -> t'
type Array, :[], '(Fixnum, Fixnum) -> Array<t>'
```

Thus if `o` is again an `Array<Fixnum>`, then `o[0]` returns a `Fixnum` and `o[0..5]` returns an `Array<Fixnum>`.

In general it's impossible to assign generic types to objects without knowing the programmer's intention. For example, consider code as simple as `x = [1,2]`. Is it the programmer's intention that `x` is an `Array<Fixnum>`? `Array<Numeric>`? `Array<Object>`?

Thus, by default, even though `Array` is declared to take type parameters, by default RDL treats array objects at the *raw* type `Array`, which means the type parameters are ignored whenever they appear in types. For our example, this means a call such as `x.push("three")` would not be reported as an error (the type signature of `Array#push` is `'(?t) -> Array<t>'`).

To fully enforce generic types, RDL requires that the developer `instantiate!` an object with the desired type parameters:

```
x = [1,2]
x.instantate!('Fixnum')
x.push("three") # type error
```

Note that the instantiated type is associated with the object, not the variable:
```
y = x
y.push("three") # also a type error
```

When RDL instantiates an object with type parameters, it needs to ensure the object's contents are consistent with the type. Currently this is enforced using the second parameter to `type_params`, which must name a method that behaves like `Array#all?`, i.e., it iterates through the contents, checking that a block argument is satisfied. As seen above, for `Array` we call `type_params(:t, :all?)`. Then at the call `x.instantiate('Fixnum')`, RDL will call `Array#all?` to iterate through the contents of `x` to check they have type `Fixnum`.

RDL also includes a `deinstantiate!` method to remove the type instantiation from an object:
```
x.deinstantiate!
x.push("three") # no longer a type error
```

Finally, `type_params` can optionally take a third argument that is an array of *variances*, which are either `:+` for covariance, `:-` for contravariance, or `:~` for invariance. If variances aren't listed, type parameters are assumed to be invariant, which is a safe default.

Variances are only used when RDL checks that one type is a subtype of another. This only happens in limited circumstances, e.g., arrays of arrays where all levels have instantiated types. So generally you don't need to worry much about the variance.

The rules for variances are standard. Let's assume `A` is a subclass of `B`. Also assume there is a class `C` that has one type parameter. Then:
* `C<A>` is a subtype of `C<A>` always
* `C<A>` is a subtype of `C<B>` if `C`'s type parameter is covariant
* `C<B>` is a subtype of `C<A>` if `C`'s type parameter is contravariant

### Tuple Types

A type such as `Array<Fixnum>` is useful for homogeneous arrays, where all elements have the same type. But Ruby programs often use heterogenous arrays, e.g., `[1, "two"]`. The best generic type we can give this is `Array<Fixnum or String>`, but that's imprecise.

RDL includes special *tuple types* to handle this situation. Tuple types are written `[t1, ..., tn]`, denoting an `Array` of `n` elements of types `t1` through `tn`, in that order. For example, `[1, "two"]` has type `[Fixnum, String]`. As another example, here is the type of `Process#getrlimit`, which returns a two-element array of `Fixnums`:

```
type Process, 'self.getrlimit', '(Symbol or String or Fixnum resource) -> [Fixnum, Fixnum] cur_max_limit'
```

### Finite Hash Types

Similarly to tuple types, RDL also supports *finite hash types* for heterogenous hashes. Finite hash types are written `{k1 => v1, ..., kn => vn}` to indicate a `Hash` with `n` mappings of type `ki` maps to `vi`. The `ki` may be strings, integers, floats, or constants denoted with `${.}`. If a key is a symbol, then the mapping should be written `ki: vi`. In the latter case, the `{}`'s can be left off:
```
type MyClass, :foo, '(a: Fixnum, b: String) { () -> %any } -> %any'
```
Here `foo`, takes a hash where key `:a` is mapped to a `Fixnum` and key `:b` is mapped to a `String`. Similarly, `{'a'=>Fixnum, 2=>String}` types a hash where keys `'a'` and `2` are mapped to a `Fixnum` and `String`, respectively. Both syntaxes can be used to define hash types.

## Other Methods

RDL also includes a few other useful methods:

* `rdl_alias(new_name, old_name)` tells RDL that method `new_name` is an alias for method `old_name`, and therefore they should have the same contracts and types. This method is only needed when adding contracts and types to method that have already been aliased; it's not needed if the method is aliased after the contract or type has been added.

* `o.type_cast(t)` returns a new object that delegates all methods to `o` but that will be treated by RDL as if it had type `t`. For example, `x = "a".type_cast('nil')` will make RDL treat `x` as if it had type `nil`, even though it's a `String`.

* `rdl_nowrap`, if called at the top-level of a class, tells RDL to record contracts and types for methods in that class but *not* enforce them. This is mostly used for the core and standard libraries, which have trustworthy behavior hence enforcing their types and contracts is not worth the overhead.

# Bibliography

Here we list some papers on various systems we built exploring contracts, types and Ruby.

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
[The Ruby Intermediate Langauge](http://www.cs.umd.edu/~jfoster/papers/dls09-ril.pdf).
In Dynamic Languages Symposium (DLS), pages 89–98, Orlando, Florida, October 2009.

* Michael Furr, Jong-hoon (David) An, and Jeffrey S. Foster.
[Profile-Guided Static Typing for Dynamic Scripting Languages](http://www.cs.umd.edu/~jfoster/papers/oopsla09.pdf).
In ACM SIGPLAN International Conference on Object-Oriented Programming, Systems, Languages and Applications (OOPSLA), pages 283–300, Orlando, Floria, October 2009. Best student paper award.

* Michael Furr, Jong-hoon (David) An, Jeffrey S. Foster, and Michael Hicks.
[Static Type Inference for Ruby](http://www.cs.umd.edu/~jfoster/papers/oops09.pdf).
In Object-Oriented Program Languages and Systems (OOPS) Track at ACM Symposium on Applied Computing (SAC), pages 1859–1866, Honolulu, Hawaii, March 2009.

# Copyright

Copyright (c) 2014-2015, University of Maryland, College Park. All rights reserved.

# Contributors

## Authors

* [Jeffrey S. Foster](http://www.cs.umd.edu/~jfoster/)
* [Brianna M. Ren](https://www.cs.umd.edu/~bren/)
* [T. Stephen Strickland](https://www.cs.umd.edu/~sstrickl/)
* Alexander T. Yu

# RDL Build Status

[![Build Status](https://travis-ci.org/plum-umd/rdl.svg?branch=master)](https://travis-ci.org/plum-umd/rdl)

# TODO list

* ProcContract, Wrap, MethodType, support higher-order contracts for blocks
  * And higher-order type checking
  * Block passed to contracts don't work yet

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

* included versus extended modules, e.g., Kernel is included in
+  Object, so its class methods become Object's instance methods.

* Better story for different types for different Ruby versions.

* Better query facility (more kinds of searches). Contract queries?

* Write documentation on: Raw Contracts and Types, RDL Configuration, Code Overview
