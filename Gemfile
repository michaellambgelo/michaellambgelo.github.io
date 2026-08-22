source "https://rubygems.org"

# Hello! This is where you manage which Jekyll version is used to run.
# When you want to use a different version, change it below, save the
# file and run `bundle install`. Run Jekyll with `bundle exec`, like so:
#
#     bundle exec jekyll serve
#
# This will help ensure the proper Jekyll version is running.
# Happy Jekylling!

gem "jekyll", "~> 3.9.3"

# Pin ffi to a version compatible with Ruby 2.6–3.1
gem "ffi", "~> 1.15.5"

# If you have any plugins, put them here!
group :jekyll_plugins do
  gem "jekyll-feed", "~> 0.15.1"
  gem "jekyll-admin"
  gem "jekyll-paginate"
  gem "jekyll-seo-tag"
  gem "kramdown-parser-gfm"
  gem "jekyll-redirect-from"
end

# Windows and JRuby does not include zoneinfo files, so bundle the tzinfo-data gem
# and associated library.
platforms :mingw, :x64_mingw, :mswin, :jruby do
  gem "tzinfo", "~> 1.2"
  gem "tzinfo-data"
end

# Performance-booster for watching directories on Windows
gem "wdm", "~> 0.2.0", :platforms => [:mingw, :x64_mingw, :mswin]

# Required for serving
# Security pin: >= 1.8.2 fixes CVE-2025-6442 (HTTP request/response smuggling)
gem "webrick", ">= 1.8.2"

# Security pin: rack >= 2.2.23 clears the outstanding rack 2.x advisories.
# Stays on the 2.x line (sinatra 3.2.0 requires rack ~> 2.2, >= 2.2.4)
# and needs only ruby >= 2.3, so it is safe under the 2.7.4 pin.
gem "rack", "~> 2.2.23"

# Security pin: addressable >= 2.9.0 clears CVE-2026-35611 (high-severity
# ReDoS). Transitive via jekyll/octokit, so a direct pin is the mechanism
# for raising the floor. Needs only ruby >= 2.2.
gem "addressable", ">= 2.9.0"

# Security pin: concurrent-ruby >= 1.3.7 clears CVE-2026-54904/54905/54906.
# Transitive via i18n (~> 1.0), which 1.3.7 satisfies. Needs ruby >= 2.3.
gem "concurrent-ruby", ">= 1.3.7"

# Fix faraday retry warning
gem "faraday-retry"
