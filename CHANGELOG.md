# Change Log
This project adheres to [Semantic Versioning](http://semver.org/).

This CHANGELOG follows [this format](https://github.com/sensu-plugins/community/blob/master/HOW_WE_CHANGELOG.md).

## [Unreleased]
### Changed
- Don't escape HTML, since RocketChat doesn't support HTML formatting.
- Don't format the output as code, since newlines are not supported. If there
  are newlines between backticks, then RocketChat does not format the text as
  code and shows the backticks.


## 1.0.1 - 2018-11-20
### Added
- Initial release
