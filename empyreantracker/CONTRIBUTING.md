# Contributing

Pull requests welcome!

## Automation

All code is covered by automated tests. Pull requests are expected to follow the same. Don't be scared - it's actually pretty fun! This was my first addon built with tests.

To run tests, you'll need one of the two options:

1. Docker installed. Run the tests with ``docker run -ti -v `pwd`:/app xurion/busted-runner`` (recommended)
2. [Busted](https://olivinelabs.com/busted/) and run it directly. See their site for configuration and commands.

The Docker option above uses my own Busted image and I prefer it to using Busted directly.

## Mocks

Due to the need of mocking Lua functions from Windower, a number of mock files can be found in [spec/mock](spec/mock). Feel free to add to this list of mocks if you want to access a function that isn't mocked yet.

Because not everything external to addons is accessed via the `require(...)` function, the before_each hook in the test file contains a number of definitions for Windower functions, such as `windower.register_event` and `windower.ffxi.get_items`.

Take a look at the structure of an existing mock - they're pretty simple and only contain empty functions.
