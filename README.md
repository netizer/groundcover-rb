# Groundcover

Groundcover is a programming language. It's a frontend of Forest language, which means that you can do with it whatever you can do with Forest.

I implemented Forest because I wanted to implement Lamb language, and somehow implementing the two of them was easier than implementing one. But Forest is damn hard to write (it's extremely verbose), so one day I built Groundcover so I didn't have to ever write code in Forest (Forest is for machines, not people).

It has a nice feature - it has a 1-1 mapping to Forest, so you can compile it to Forest, then compile it back to Greoundcover and you'll get exactly the initial code. It's cool because I keep working on Groundcover, and thanks to that I don't have to manually translate the old Groundcover code to the the new format. I just use the old compiler to translate it back to Forest, and then the new compiler to translate it again to Groundcover. I don't know any compiler that does that, and I wanted to refer to it somehow (it sucks to talk about things without using names - I'm sure the ones who did not like Voldemort know exactly what I'm talking about), so I ended up refering to it as **symmetric compilation**. If you know a better name, or, even better, if you know about an existing project with such feature, you'll make my day if you create a github issue for this repo and suggest a better name.

It's actually pretty simple. Groundcover is a superset of Forest. It just has more keywords (Forest has only 3), and allows writing more terse expressions. This means that the symmetry is not absolute. You can write a Forest code, change the file extension to ".forest" and compile it to Groundcover, and yes, the file you'll get will not be the same that you wrote, but,... drumroll... it will actually be better (more terse - and if you can write a more terse code in Groundover, you definitely should). Overall it doesn't work very bad. Hmm, It actually works quite well. Well, to be honest, it feels like riding a unicorn in Neverland, or like having your own robot writting code for you. It's just, you have to explain to it what you want with... surpise, suprise.. code,... so, after all, maybe it's not so amazing, but I quite like it.

## How does it look?

Here is a code in Forest. Pretty verbose. Don't you think?
```forest
call
  data
    cgs.context
  block
    call
      data
        cgs.set
      block
        data
          first_function
        call
          data
            ln.later
          call
            data
              testing.log
            block
              data
                defined first
```

Here is a Groundcover counterpart.

```groundcover
m:context
  m:set first_function
    m:later
      m:testing_log
        data
          defined first
```

## Usage

If you want to play with the compilation process, you can remove `fixtures/later_now.forest` and then call this:

```bash
ruby run.rb fixtures/later_now.gc
```

If, on the other hand, you'd like Forest to be able to parse Groundcover files, just include module Lamb to Forest Dependencies (which is already done if you use `bin/forest.rb` from `forest-rb` repository). To see how it's done, you can also check out the test in `spec/ruby_usage_spec.rb` in that repository.

If you'd like to affect the compilation process, check out the file `templates.forest`. It's basically a list of all patterns that the compiler recognises in Forest and Groundcover code with the info of how they map to themselves. For example this part of the templates file:

```forest
block
  data
    m:assert
      $body
  data
    call
      data
        testing.assert
      block
        $body
```

means that every snippet:

```groundcover
m:assert
  SOMETHING
```        

in the Groundcover file will map to

```forest
call
  data
    testing.assert
  block
    SOMETHING
```

in the Forest file, and the other way around.

## Status of the language

It is work in progress. I think it will become even more verbose pretty soon. I hope I'll find a good way to express more in a single line of code without negatively affecting readability.

## Community

I experiment with a couple of ideas, and you can expect a lot to chages, but thanks to symmetric compilation, the changes should not cause any headaches. If you find this project interesting, feel free to create github issues with suggestions, comments or even questions. This way we can communicate in an async way and others could benefit from the conversation.
