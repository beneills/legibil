[![Build Status](https://travis-ci.org/beneills/legibil.svg?branch=master)](https://travis-ci.org/beneills/legibil)
[![Code Climate](https://codeclimate.com/github/beneills/legibil/badges/gpa.svg)](https://codeclimate.com/github/beneills/legibil)
[![Coverage Status](https://coveralls.io/repos/github/beneills/legibil/badge.svg?branch=master)](https://coveralls.io/github/beneills/legibil?branch=master)
[![Dependency Status](https://gemnasium.com/beneills/legibil.svg)](https://gemnasium.com/beneills/legibil)

# Legibil #

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

```bash
 git clone https://github.com/beneills/legibil.git
 cd legibil
 bundle install
 foreman start # launch development environment
```

## Views ##

* __Focus View:__ see the area(a) of user focus for an endpoint
