<h3 align="center">
<img src="/assets_readme/logo.png" alt="xcov Logo" />
</h3>

-------

[![Twitter: @carlostify](https://img.shields.io/badge/contact-@carlostify-blue.svg?style=flat)](https://twitter.com/carlostify)
[![License](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/nakiostudio/xcov/blob/master/LICENSE)
[![Gem](https://img.shields.io/gem/v/danger-xcov.svg?style=flat)](http://rubygems.org/gems/danger-xcov)
[![Gem Downloads](https://img.shields.io/gem/dt/danger-xcov.svg?style=flat)](http://rubygems.org/gems/danger-xcov)

**danger-xcov** is the [Danger](https://github.com/danger/danger) plugin of
[xcov](https://github.com/nakiostudio/xcov), a friendly visualizer for Xcode's
code coverage files.

## Installation

```
sudo gem install danger-xcov
```

## Usage

Simply add `xcov.report` to your `Dangerfile` passing those **xcov** parameters
you need. Click [here](https://github.com/nakiostudio/xcov#parameters-allowed) to
see the updated list of parameters allowed by **xcov**.

```ruby
xcov.report(
   scheme: 'EasyPeasy',
   workspace: 'Example/EasyPeasy.xcworkspace',
   exclude_targets: 'Demo.app',
   minimum_coverage_percentage: 90
)
```

The result is as cool as follows:

<h3 align="center">
<img src="/assets_readme/xcov_danger.png" />
</h3>

## License
This project is licensed under the terms of the MIT license. See the LICENSE file.
