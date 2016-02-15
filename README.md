[![Build Status](https://travis-ci.org/beneills/ux.svg?branch=master)](https://travis-ci.org/beneills/ux)
[![Code Climate](https://codeclimate.com/github/beneills/ux/badges/gpa.svg)](https://codeclimate.com/github/beneills/ux)
[![Coverage Status](https://coveralls.io/repos/github/beneills/ux/badge.svg?branch=development)](https://coveralls.io/github/beneills/ux?branch=development)
[![Dependency Status](https://gemnasium.com/beneills/ux.svg)](https://gemnasium.com/beneills/ux)

# ux #

__A web app for automated UX testing.__



## Dependencies ##


* ruby-rails
* imagemagick
* a running redis server (for sidekiq)
* one of (in order of preference):
** phantomjs, or
** firefox with running X server, or
** webkit2png

## Development ##

Run `bin/development-environment` from the root ux directory to launch a development environment.

## Views ##

* __Focus View:__ see the area(a) of user focus for an endpoint
