# GithubAPI

[![Gem Version](https://badge.fury.io/rb/github_api.png)][gem]
[![Build Status](https://secure.travis-ci.org/peter-murach/github.png?branch=master)][travis]
[![Dependency Status](https://gemnasium.com/peter-murach/github.png?travis)][gemnasium]
[![Code Climate](https://codeclimate.com/github/peter-murach/github.png)][codeclimate]
[![Coverage Status](https://coveralls.io/repos/peter-murach/github/badge.png?branch=master)][coveralls]

[gem]: http://badge.fury.io/rb/github_api
[travis]: http://travis-ci.org/peter-murach/github
[gemnasium]: https://gemnasium.com/peter-murach/github
[codeclimate]: https://codeclimate.com/github/peter-murach/github
[coveralls]: https://coveralls.io/r/peter-murach/github

[Website](http://peter-murach.github.io/github/) | [Wiki](https://github.com/peter-murach/github/wiki) | [RDocs](http://rubydoc.info/github/peter-murach/github/master/frames)

A Ruby wrapper for the GitHub REST API v3.

Supports all the API methods. It's built in a modular way. You can either instantiate the whole API wrapper Github.new or use parts of it i.e. Github::Repos.new if working solely with repositories is your main concern.

## Features

* Intuitive GitHub API interface navigation. [usage](#usage)
* Modular design allows for working with parts of API. [api](#api)
* Fully customizable including advanced middleware stack construction. [config](#advanced-configuration)
* It's comprehensive. You can request all GitHub API resources.
* Supports OAuth2 authorization. [oauth](#oauth)
* Flexible argument parsing. You can write expressive and natural queries. [params](#arguments--parameters)
* Requests pagination with convenient DSL and automatic options. [pagination](#pagination)
* Easy error handling split for client and server type errors. [error](#error-handling)
* Supports multithreaded environment.
* Custom media type specification through the 'media' parameter. [media](#media-types)
* Request results caching (Status: TODO)
* Fully tested with test coverage above 90% with over 1,700 specs and 1000 features. [testing](#testing)

## Installation

Install the gem by running

```ruby
gem install github_api
```

or put it in your Gemfile and run `bundle install`

```ruby
gem "github_api"
```

## Contents

* [1. Usage](#1-usage)
* [2. Arguments & Parameters](#2-arguments--parameters)
* [3. Advanced Configuration](#3-advanced-configuration)
* [4. Authentication](#4-authentication)
* [5. SSL](#5-ssl)
* [6. API](#6-api)
* [7. Media Types](#7-media-types)
* [8. Hypermeida](#8-hypermedia)
* [9. Configuration](#9-configurations)
* [10. Pagination](#10-pagination)
* [11. Caching](#11-caching)
* [12. Debugging](#12-debugging)
* [13. Error Handling](#13-error-handling)
* [14. Response Message](#14-response-message)
* [15. Examples](#15-examples)
* [16. Testing](#16-testing)

## 1 Usage

To start using the gem, you can either perform direct calls on `Github`

```ruby
Github.repos.list user: 'wycats'
```

or create a new client instance

```ruby
github = Github.new
```

### 1.1 Options

At this stage, you can also supply various configuration parameters, such as
```
  adapter          # http client used for performing requests
  auto_pagination  # false by default, set to true to traverse requests page links
  oauth_token      # oauth authorization token
  basic_auth       # login:password string
  client_id        # oauth client id
  client_secret    # oauth client secret
  user             # global user used in requests if none provided
  repo             # global repository used in requests in none provided
  org              # global organization used in requests if none provided
  endpoint         # enterprise API endpoint
  site             # enterprise API web endpoint
  ssl              # SSL settings
  per_page         # number of items per page- max of 100
  user_agent       # custom user agent name, 'Github API' by default
```
which are used throughout the API. These can be passed directly as hash options:

```ruby
github = Github.new oauth_token: 'token'
```

Alternatively, you can configure the GitHub settings by passing a block, for instance, for a custom enterprise endpoint and website like

```ruby
github = Github.new do |config|
  config.endpoint    = 'https://github.company.com/api/v3'
  config.site        = 'https://github.company.com'
  config.oauth_token = 'token'
  config.adapter     = :net_http
  config.ssl         = {:verify => false}
end
```

You can authenticate either using OAuth authentication convenience methods (see OAuth section) or through basic authentication by passing your login and password credentials

```ruby
github = Github.new login:'peter-murach', password:'...'
```

or using a convenience method:

```ruby
github = Github.new basic_auth: 'login:password'
```

### 1.2 API navigation

This gem closely mirrors the GitHub API hierarchy i.e. if you want to create a download resource,
look up the GitHub API spec and issue the request as in `github.repos.downloads.create`

For example to interact with GitHub Repositories API, issue the following calls that correspond directly to the GitHub API hierarchy

```ruby
github.repos.commits.all  'user-name', 'repo-name'
github.repos.hooks.create 'user-name', 'repo-name', name: "web", active: true
github.repos.keys.get     'user-name', 'repo-name'
```

### 1.3 Modularity

The code base is modular and allows for you to work specifically with a given part of GitHub API e.g. blobs

```ruby
blobs = Github::GitData::Blobs.new
blobs.create 'peter-murach', 'github', content: 'Blob content'
```

### 1.4 Response querying
The response is of type [Github::ResponseWrapper] which allows traversing all the json response attributes like method calls i.e.

```ruby
repos = Github::Repos.new user: 'peter-murach', repo: 'github'
repos.branches do |branch|
  puts branch.name
end
```

## 2 Arguments & Parameters

The **GithubAPI** library allows for flexible argument parsing. Therefore, arguments can be passed during instance creation:

```ruby
  issues = Github::Issues.new user: 'peter-murach', repo: 'github'
  issues.milestones.list state: 'open'
```

Further, arguments can be passed directly inside the method called, but then the order of parameters matters and hence please consult the method documentation or GitHub specification. For instance:

```ruby
  issues = Github::Issues.new
  issues.milestones.list 'peter-murach', 'github', state: 'open'
```

Similarly, the arguments for the request can be passed inside the current scope such as:

```ruby
  issues = Github::Issues.new
  issues.milestones(user: 'peter-murach', repo: 'github').list
```

But why limit ourselves? You can mix and match arguments, for example:

```ruby
  issues = Github::Issues.new user: 'peter-murach'
  issues.milestones(repo: 'github').list
  issues.milestones(repo: 'tty').list
```

You can also use a bit of syntactic sugar common among Ruby libraries whereby "username/repository" can be passed as well:

```ruby
  issues = Github::Issues.new
  issues.milestones('peter-murach/github').list
  issues.milestones.list 'peter-murach/github'
```

Finally, use the `with` scope to clearly denote your requests

```ruby
  issues = Github::Issues.new
  issues.milestones.with(user: 'peter-murach', repo: 'github').list
```

Some API methods apart from required parameters such as username, repository name
or organisation name, allow you to switch the way the data is returned to you, for instance

```ruby
github = Github.new
github.git_data.trees.get 'peter-murach', 'github', 'c18647b75d72f19c1e0cc8af031e5d833b7f12ea'
# => gets a tree

github.git_data.trees.get 'peter-murach', 'github', 'c18647b75d72f19c1e0cc8af031e5d833b7f12ea',
  recursive: true # => gets a whole tree recursively
```

by passing a block you can iterate over the file tree

```ruby
github.git_data.trees.get 'peter-murach', 'github', 'c18647b75d72f19c1e0cc8af031e5d833b7f12ea',
  recursive: true do |file|
    puts file.path
end
```

## 3 Advanced Configuration

The `github_api` gem will use the default middleware stack which is exposed by calling `stack` on a client instance. However, this stack can be freely modified with methods such as `insert`, `insert_after`, `delete` and `swap`. For instance, to add your `CustomMiddleware` do

```ruby
github = Github.new do |config|
  config.stack.insert_after Github::Response::Helpers, CustomMiddleware
end
```

Furthermore, you can build your entire custom stack and specify other connection options such as `adapter`

```ruby
github = Github.new do |config|
  config.adapter :excon

  config.stack do |builder|
    builder.use Github::Response::Helpers
    builder.use Github::Response::Jsonize
  end
end
```

## 4 Authentication

### 4.1 Basic

To start making requests as authenticated user you can use your GitHub username and password like so

```ruby
Github.new basic_auth: 'login:password'
```

Though this method is convenient you should strongly consider using `OAuth` for improved security reasons.

### 4.2 Application OAuth access

In order to authenticate your app through OAuth2 on GitHub you need to

* Visit https://github.com/settings/applications/new and register your app.
  You will need to be logged in to initially register the application.

* Authorize your credentials https://github.com/login/oauth/authorize

You can use convenience methods to help you achieve this using **GithubAPI** gem:

```ruby
github = Github.new client_id: '...', client_secret: '...'
github.authorize_url redirect_uri: 'http://localhost', scope: 'repo'
# => "https://github.com/login/oauth/authorize?scope=repo&response_type=code&client_id='...'&redirect_uri=http%3A%2F%2Flocalhost"
```
After you get your authorization code, call to receive your access_token

```ruby
token = github.get_token( authorization_code )
```

Once you have your access token, configure your github instance following instructions under Configuration.

**Note**: If you are working locally (i.e. your app URL and callback URL are localhost), do not specify a ```:redirect_uri``` otherwise you will get a ```redirect_uri_mismatch``` error.

### 4.3 Authorizations API

#### 4.3.1 For an User

To create an access token through the GitHub Authrizations API, you are required to pass your basic credentials and scopes you wish to have for the authentication token.

```ruby
github = Github.new basic_auth: 'login:password'
github.oauth.create scopes: ['repo']
```

You can add more than one scope from the `user`, `public_repo`, `repo`, `gist` or leave the scopes parameter out, in which case, the default read-only access will be assumed (includes public user profile info, public repo info, and gists).

#### 4.3.2 For an App

Furthermore, to create auth token for an application you need to pass `:app` argument together with `:client_id` and `:client_secret` parameters.

```ruby
github = Github.new basic_auth: 'login:password'
github.oauth.app.create 'client-id', scopes: ['repo']
```

In order to revoke auth token(s) for an application you must use basic authentication with `client_id` as login and `client_secret` as password.

```ruby
github = Github.new basic_auth: "client_id:client_secret"
github.oauth.app.delete 'client-id'
```

Revoke a specific app token.

```ruby
github.oauth.app.delete 'client-id', 'access-token'
```

### 4.4 Scopes

You can check OAuth scopes you have by:

```ruby
  github = Github.new :oauth_token => 'token'
  github.scopes.list    # => ['repo']
```

To list the scopes that the particular GitHub API action checks for do:

```ruby
  repos = Github::Repos.new
  res = repos.list :user => 'peter-murach'
  res.headers.accepted_oauth_scopes    # => ['delete_repo', 'repo', 'public_repo', 'repo:status']
```

To understand what each scope means refer to [documentation](http://developer.github.com/v3/oauth/#scopes)

## 5 SSL

By default requests over SSL are set to OpenSSL::SSL::VERIFY_PEER. However, you can turn off peer verification by

```ruby
  Github.new ssl: { verify: false }
```

If your client fails to find CA certs, you can pass other SSL options to specify exactly how the information is sourced

```ruby
  ssl: {
    client_cert: "/usr/local/www.example.com/client_cert.pem"
    client_key:  "/user/local/www.example.com/client_key.pem"
    ca_file:     "example.com.cert"
    ca_path:     "/etc/ssl/"
  }
```

For instance, download CA root certificates from Mozilla [cacert](http://curl.haxx.se/ca/cacert.pem) and point ca_file at your certificate bundle location.
This will allow the client to verify the github.com ssl certificate as authentic.

## 6 API

Main API methods are grouped into the following classes that can be instantiated on their own

```ruby
Github         - full API access

Github::Gists           Github::GitData    Github::Repos             Github::Search
Github::Orgs            Github::Issues     Github::Authorizations
Github::PullRequests    Github::Users      Github::Activity
```

Some parts of GitHub API v3 require you to be authenticated, for instance the following are examples of APIs only for the authenticated user

```ruby
Github::Users::Emails
Github::Users::Keys
```

All method calls form Ruby like sentences and allow for intuitive API navigation, for instance

```ruby
github = Github.new :oauth_token => '...'
github.users.followers.following 'wycats'  # => returns users that 'wycats' is following
github.users.followers.following? 'wycats' # => returns true if following, otherwise false
```

For specifications on all available methods, go to http://developer.github.com/v3/ or
read the rdoc. All methods are documented there with examples of usage.

Alternatively, you can find out which methods are supported by calling `actions` on a class instance in your `irb`:

```ruby
>> Github::Repos.actions                    >> github.issues.actions
---                                         ---
|--> all                                    |--> all
|--> branches                               |--> comments
|--> collaborators                          |--> create
|--> commits                                |--> edit
|--> contribs                               |--> events
|--> contributors                           |--> find
|--> create                                 |--> get
|--> downloads                              |--> labels
|--> edit                                   |--> list
|--> find                                   |--> list_repo
|--> forks                                  |--> list_repository
|--> get                                    |--> milestones
|--> hooks                                  ...
...
```

## 7 Media Types

You can specify custom media types to choose the format of the data you wish to receive. To make things easier you can specify the following shortcuts
`json`, `blob`, `raw`, `text`, `html`, `full`. For instance:

```ruby
github = Github.new
github.issues.get 'peter-murach', 'github', 108, media: 'text'
```

This will be expanded into `application/vnd.github.v3.text+json`

If you wish to specify the version, pass `media: 'beta.text'` which will be converted to `application/vnd/github.beta.text+json`.

Finally, you can always pass the whole accept header like so

```ruby
github.issues.get 'peter-murach', 'github', 108, accept: 'application/vnd.github.raw'
```

## 8 Hypermedia

TODO

## 9 Configuration

Certain methods require authentication. To get your GitHub OAuth v2 credentials,
register an app at https://github.com/settings/applications/
You will need to be logged in to register the application.

```ruby
Github.configure do |config|
  config.oauth_token   = YOUR_OAUTH_ACCESS_TOKEN
  config.basic_auth    = 'login:password'
end

or

Github.new(:oauth_token => YOUR_OAUTH_TOKEN)
Github.new(:basic_auth => 'login:password')
```

All parameters can be overwritten each method call by passing a parameters hash.


By default, no caching will be performed. In order to set the cache do... If no cache type is provided, a default memoization is done.

## 10 Pagination

Any request that returns multiple items will be paginated to 30 items by default. You can specify custom `page` and `per_page` query parameters to alter default behavior. For instance:

```ruby
repos = Github::Repos.new
repos.list user: 'wycats', per_page: 10, page: 5
```

Then you can query the pagination information included in the link header by:

```ruby
res.links.first  # Shows the URL of the first page of results.
res.links.next   # Shows the URL of the immediate next page of results.
res.links.prev   # Shows the URL of the immediate previous page of results.
res.links.last   # Shows the URL of the last page of results.
```

In order to iterate through the entire result set page by page, you can use convenience methods:

```ruby
res.each_page do |page|
  page.each do |repo|
    puts repo.name
  end
end
```

or use `has_next_page?` and `next_page` like in the following:

```ruby
while res.has_next_page?
  ... process response ...
  res.next_page
end
```

Alternatively, you can retrieve all pages in one invocation by passing the `auto_pagination` option like so:

```ruby
  github = Github.new auto_pagination: true
```

Depending at what stage you pass the `auto_pagination` it will affect all or only a single request:

```ruby
  Github::Repos.new auto_pagination: true         # affects Repos part of API

  Github::Repos.new.list user: '...', auto_pagination: true  # affects a single request
```

One can also navigate straight to the specific page by:

```ruby
res.count_pages  # Number of pages
res.page 5       # Requests given page if it exists, nil otherwise
res.first_page   # Get first page
res.next_page    # Get next page
res.prev_page    # Get previous page
res.last_page    # Get last page
```

## 11 Caching

Caching is supported through the [`faraday-http-cache` gem](https://github.com/plataformatec/faraday-http-cache).

Add the gem to your Gemfile:

    gem 'faraday-http-cache'

You can now configure cache parameters as follows

```ruby
Github.configure do |config|
  config.stack do |builder|
    builder.use Faraday::HttpCache, store: Rails.cache
  end
end
```

More details on the available options can be found in the gem's own documentation: https://github.com/plataformatec/faraday-http-cache#faraday-http-cache

## 12 Debugging

run with ENV['DEBUG'] flag  or include middleware by passing `debug` flag

## 13 Error Handling

The generic error class `Github::Error::GithubError` will handle both the client (`Github::Error::ClientError`) and service (`Github::Error::ServiceError`) side errors. For instance in your code you can catch errors like

```ruby
begin
  # Do something with github_api gem
rescue Github::Error::GithubError => e
  puts e.message

  if e.is_a? Github::Error::ServiceError
    # handle GitHub service errors such as 404
  elsif e.is_a? Github::Error::ClientError
    # handle client errors e.i. missing required parameter in request
  end
end
```

## 14 Response Message

Each response comes packaged with methods allowing for inspection of HTTP start line and headers. For example, to check for rate limits and status codes, call

```ruby
res = Github::Repos.new.branches 'peter-murach', 'github'
res.headers.ratelimit_limit     # "5000"
res.headers.ratelimit_remainig  # "4999"
res.headers.status              # "200"
res.headers.content_type        # "application/json; charset=utf-8"
res.headers.etag                # "\"2c5dfc54b3fe498779ef3a9ada9a0af9\""
res.headers.cache_control       # "public, max-age=60, s-maxage=60"
```

## 15 Examples

Some API methods require input parameters. These are simply added as a hash of properties, for instance

```ruby
issues = Github::Issues.new user:'peter-murach', repo: 'github-api'
issues.milestones.list state: 'open', sort: 'due_date', direction: 'asc'
```

Other methods may require inputs as an array of strings

```ruby
users = Github::Users.new oauth_token: 'token'
users.emails.add 'email1', 'email2', ..., 'emailn' # => Adds emails to the authenticated user
```

If a method returns a collection, you can iterate over it by supplying a block parameter,

```ruby
events = Github::Activity::Events.new
events.public do |event|
  puts event.actor.login
end
```

Query requests return boolean values instead of HTTP responses

```ruby
github = Github.new
github.orgs.members.member? 'github', 'technoweenie', public: true # => true
```

### 15.1 Rails Example

A Rails controller that allows a user to authorize their GitHub account and then performs a request.

```ruby
class GithubController < ApplicationController

  attr_accessor :github
  private :github

  def authorize
    github  = Github.new client_id: '...', client_secret: '...'
    address = github.authorize_url redirect_uri: 'http://...', scope: 'repo'
    redirect_to address
  end

  def callback
    authorization_code = params[:code]
    access_token = github.get_token authorization_code
    access_token.token   # => returns token value
  end
end
```

## 16 Testing

The test suite is split into two groups, `live` and `mock`.

The `live` tests are the ones in `features` folder and they simply exercise the GitHub API by making live requests and then being cached with VCR in directory named `features\cassettes`. For details on how to get set up, please navigate to the `features` folder.

The `mock` tests are in the `spec` directory and their primary concern is to test the gem internals without the hindrance of external calls.

## Development

Questions or problems? Please post them on the [issue tracker](https://github.com/peter-murach/github/issues). You can contribute changes by forking the project and submitting a pull request. You can ensure the tests are passing by running `bundle` and `rake`.

## Copyright

Copyright (c) 2011-2014 Piotr Murach. See LICENSE.txt for further details.
