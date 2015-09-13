# Introduction

RDL is...

# Guided Tour

# RDL Reference

## Installing RDL

`gem install rdl` should do it.

## Loading RDL

Use `require 'rdl'` to load the RDL library. If you want to use the
core and standard library type signatures that come with RDL, follow
it with `require 'rdl_types'`.

If you're using Ruby on Rails, add the following lines in
`application.rb` after the `Bundler.require` call. (This placement is
needed so the Rails version string is available and the Rails
environment is loaded):

```
require 'rdl'
require 'rdl_types'
require 'rails_types'
```

## Preconditions and Postconditions

## Type Signatures

## Other Methods

## RDL Configuration

# Code Overview

## RDL and Rails


# RDL Build Status

[![Build Status](https://travis-ci.org/plum-umd/rdl.png?branch=cRDL)](https://travis-ci.org/plum-umd/rdl)

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