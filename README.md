# TForest

## Usage

```bash
ruby run.rb fixtures/later_now.tforest
```

## Goals

TForest (or forest with templates) is one of the programming languages built on top of Forest. There are 2 goals of this language:
1. To show how to build a language on top of forest.
2. To build a language that is as close to forest as possible but in the same time is more readable for humans.

To achieve the goal nr 1, even if this language is so simple that a different form of implementation might seem more adequate (e.g. it could be part of forest itself, or we could make this language extandable to be able to add new templates), it's going to be implemented so that there was as mmuch as possible in common between the way the compilation process works in here and in case of lamb.

To achieve the goal nr 2, we'll just make it a superset of Forest, and will add a small set of powerful syntactic sugar constructs on top of it.

### Re 1.

To build a language (X) on top of forest we'll need:
1. A forest code that will be used as a compiler of every file written in X
2. A set of modules in forest language, that can be included by the former

(have in mind that every module written in forest has a list of 2-word names of capabilities that it depends on; you can choose the actual module providing these capablities; 2-word names are for example like follows: `math kher`, where the second name is a variant of the interface of the `math` module; there might be several implementations of the same interface, and w different modules with the same first word can have the same interface)

### Re 2.

TForest is a superset of Forest, so you can write Forest code and it will be a valid TForest code too, but not the other way around. TForest introduces the following, new keyword: `macro`. It also introduces the following naming convention: **All the function names starting with `m:` are refering to macros.**

This is how it works:

Here is a very verbose code that we want to build a macro for:
```
call
  block
    data
      module.function_name
    context
      tesing.log
        data
          asd
```
So we call macro in the following way:
```
macro
  data
    block
      data
        $head
      $body
```
And we can generate the same function by calling just that:
```
m:call module.function_name
  context
    testing.log
      data
        asd
```
