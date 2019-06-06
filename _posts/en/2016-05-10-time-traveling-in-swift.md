---
lang: en
layout: post
title: "Time Traveling in Swift"
excerpt: 'Building a sweet syntax of relative time using extensions in Swift.'
published: false
---

![time traveling](/public/images/time-traveling.jpg)
<span class="notes">photo by [Tristan Colangelo](https://unsplash.com/@tcrawlers)</span>

<br />

Just in case you don’t know, there’s a cool stuff called `extension` in Swift.

You can create additional features for a `class` or a `struct` using `extension`.

<br />

Today I’m going to share a little snippet that is inspired by [ActiveSupport](https://github.com/rails/rails/tree/master/activesupport).

In Rails, you can manipulate time like this:

```ruby
3.days.ago # 2016-05-07 15:31:40 +0800

2.weeks.from_now # 2016-05-24 15:31:49 +0800
```

This is one of my favorite features in Rails. It’s built using [monkey patches](http://stackoverflow.com/questions/394144/what-does-monkey-patching-exactly-mean-in-ruby).

Though `extension` in Swift is not exactly the same as monkey patching, we can still use it to create cool features like the way ActiveSupport does.

<hr />

Let’s get our hands dirty!

The basic syntax of `extension` looks like this:

```swift
extension ClassName {
  // put your additional features here!
}
```

Say if we have a `Bear` class, and we’d like to teach the bears how to code, we can use `extension` like this:

```swift
class Bear {
  var name = ""

  init(name: String) {
    self.name = name
  }
  // other stuffs ...
}

extension Bear {
  func code() {
    print("\(name) is coding! ⌨️")
  }
}

let teddy = Bear(name: "Teddy")
teddy.code() // Teddy is coding! ⌨️
```

Having the syntax in mind, we’re ready do play with time using Swift.

<hr />

We’re going to make extensions of `Int`, you can do the same thing to `Double` if you’d like to.

First of all, we make an extension that converts an `Int` to **seconds** which is an `Int` with same value:

```swift
extension Int {
  var seconds: Int { return self }
}

3.seconds // 3
```

And we can add some more time units:

```swift
extension Int {
  var seconds: Int { return self }
  var minutes: Int { return self * 60.seconds }
  var hours: Int { return self * 60.minutes }
  var days: Int { return self * 24.hours }
  var weeks: Int { return self * 7.days }
}

2.minutes // 120
3.days // 259200
```

It basically converts the duration of time to seconds.

We can add more features by creating another `extension` which converts seconds into dates relative to the current time:

```swift
extension Int {
  var ago: NSDate {
    return NSDate(timeIntervalSinceNow: NSTimeInterval(-1 * self))
  }

  var fromNow: NSDate {
    return NSDate(timeIntervalSinceNow: NSTimeInterval(self))
  }
}

3.days.ago // May 7, 2016, 3:53 PM
```

Putting stuffs together:

```swift
// Int+RelativeTime.swift

extension Int {
  var seconds: Int { return self }
  var minutes: Int { return self * 60.seconds }
  var hours: Int { return self * 60.minutes }
  var days: Int { return self * 24.hours }
  var weeks: Int { return self * 7.days }
}

extension Int {
  var ago: NSDate {
    return NSDate(timeIntervalSinceNow: NSTimeInterval(-1 * self))
  }

  var fromNow: NSDate {
    return NSDate(timeIntervalSinceNow: NSTimeInterval(self))
  }
}
```

You can use this really sweet syntax you just created!

**What’s the best `extension` you’ve ever written or seen? Leave a comment and tell me about it!**
