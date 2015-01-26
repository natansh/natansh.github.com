---
layout: post
title: Schönfinkelization
---

I was amused by the name when I came across this technique while reading the book *Javscript Patterns* by _Stoyan Stefanov_. Schönfinkelization is just another name for a technique called _Currying_, but somehow, this name seems cool, right? ;-) 

To understand what _Currying_ is, we first need to understand _partial function application_. Intuitively, it just means that "if I fix the first arguments of a function, I get a function that takes the remaining arguments".

_Currying_ then, is the process of making a function capable of handling _partial application_. The basic idea of _Currying_ is to transform a function requiring `n` arguments into a chain of functions, each taking a single argument. This allows us to fix the first few arguments to get a new function that will take the rest of the arguments, which is exactly what we need for _partial application_. In the book, Stoyan gave a generic function `schonfinkelize` to enable this behavior for all such functions -

{% highlight javascript %}
function schonfinkelize(fn) {
  var slice = Array.prototype.slice,
    oldArgs = slice.call(arguments, 1);
  return function() {
    var newArgs = slice.call(arguments),
      args = oldArgs.concat(newArgs);
    return fn.apply(null, args);
  };
}
{% endhighlight %}

If you look carefully, most of the code is just there to get over the limitation that `arguments` is not an array but an array-like object. If `arguments` was an array, the function would've been much simpler, and then it is easier to see the gist of what the `schonfinkelize` function does.

{% highlight javascript %}
// This is NOT working code. It assumes `arguments` is an array.

function schonfinkelize(fn) {
  var oldArgs = arguments.slice(1);
  return function() {
    return fn.apply(null, oldArgs.concat(arguments));
  };
}
{% endhighlight %}

Of course, once this generalized function is defined, it is easy to use it.

{% highlight javascript %}
// Function that we want to schonfinkelize (or curry)
function multiply(a, b) {
  return a * b;
}

// Partial application
var multiplySc = schonfinkelize(multiply, 10);

// Final result
var result = multiplySc(10); // 100
{% endhighlight %}

REFERENCES:
1. Javascript Patterns by Stoyan Stefanov 
2. [Wikipedia - Currying](http://en.wikipedia.org/wiki/Currying)
