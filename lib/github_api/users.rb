# encoding: utf-8

module Github
  class Users < API
    extend AutoloadHelper

    # Load all the modules after initializing Repos to avoid superclass mismatch
    autoload_all 'github_api/users',
      :Emails    => 'emails',
      :Followers => 'followers',
      :Keys      => 'keys'

    VALID_USER_PARAMS_NAMES = %w[
      name
      email
      blog
      company
      location
      hireable
      bio
    ].freeze

    # Creates new Repos API
    def initialize(options = {})
      super(options)
    end

    # Access to Users::Emails API
    def emails
      @emails ||= ApiFactory.new 'Users::Emails'
    end

    # Access to Users::Followers API
    def followers
      @followers ||= ApiFactory.new 'Users::Followers'
    end

    # Access to Users::Keys API
    def keys
      @keys ||= ApiFactory.new 'Users::Keys'
    end

    # List all users.
    #
    # This provides a dump of every user, in the order that they signed up
    # for GitHub.
    #
    # = Parameters
    # * <tt>:since</tt> - The integer ID of the last User that you’ve seen.
    #
    # = Examples
    #  users = Github::Users.new
    #  users.list
    #
    def list(params={})
      normalize! params

      response = get_request("/users", params)
      return response unless block_given?
      response.each { |el| yield el }
    end
    alias :all :list

    # Get a single unauthenticated user
    #
    # = Examples
    #  github = Github.new
    #  github.users.get user: 'user-name'
    #
    # Get the authenticated user
    #
    # = Examples
    #  github = Github.new oauth_token: '...'
    #  github.users.get
    #
    def get(*args)
      params = args.extract_options!
      normalize! params
      if user_name = params.delete('user')
        get_request("/users/#{user_name}", params)
      else
        get_request("/user", params)
      end
    end
    alias :find :get

    # Update the authenticated user
    #
    # = Inputs
    # * <tt>:name</tt> - Optional string
    # * <tt>:email</tt> - Optional string - publically visible email address
    # * <tt>:blog</tt> - Optional string
    # * <tt>:company</tt> - Optional string
    # * <tt>:location</tt> - Optional string
    # * <tt>:hireable</tt> - Optional boolean
    # * <tt>:bio</tt> - Optional string
    #
    # = Examples
    #  github = Github.new :oauth_token => '..'
    #  github.users.update
    #    "name" => "monalisa octocat",
    #    "email" => "octocat@github.com",
    #    "blog" => "https://github.com/blog",
    #    "company" => "GitHub",
    #    "location" => "San Francisco",
    #    "hireable" => true,
    #    "bio" => "There once..."
    #
    def update(*args)
      params = args.extract_options!
      normalize! params
      filter! VALID_USER_PARAMS_NAMES, params
      patch_request("/user", params)
    end

  end # Users
end # Github
