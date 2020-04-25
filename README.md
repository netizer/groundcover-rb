TForest (or forest with templates) is one of the programming languages built on top of Forest. The main goals of this project is to make a language that is as similar to Forest, but in the same time is more readable for humans. The way to achieve this goal is to create a small set of powerful syntactic sugar constructs on top of Forest.

In other words we want macros with a very minimalistic syntax.

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
