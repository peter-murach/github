# encoding: utf-8

module Github
  class Issues::Comments < API

    VALID_ISSUE_COMMENT_PARAM_NAME = %w[
      body
      resource
      mime_type
    ].freeze

    # Creates new Issues::Comments API
    def initialize(options = {})
      super(options)
    end

    # List comments on an issue
    #
    # = Examples
    #  github = Github.new
    #  github.issues.comments.all 'user-name', 'repo-name', issue_id: 'id'
    #  github.issues.comments.all 'user-name', 'repo-name', issue_id: 'id' {|com| .. }
    #
    # List comments in a repository
    #
    # = Parameters
    # * <tt>:sort</tt>      - Optional string, <tt>created</tt> or <tt>updated</tt>
    # * <tt>:direction</tt> - Optional string, <tt>asc</tt> or <tt>desc</tt>.
    #                         Ignored with sort parameter.
    # * <tt>:since</tt>     - Optional string of a timestamp in ISO 8601
    #                         format: YYYY-MM-DDTHH:MM:SSZ
    #
    # = Examples
    #  github = Github.new
    #  github.issues.comments.all 'user-name', 'repo-name'
    #  github.issues.comments.all 'user-name', 'repo-name' {|com| .. }
    #
    def list(user_name, repo_name, params={})
      set :user => user_name, :repo => repo_name
      assert_presence_of user, repo
      normalize! params

      response = if (issue_id = params.delete('issue_id'))
        get_request("/repos/#{user}/#{repo}/issues/#{issue_id}/comments", params)
      else
        get_request("/repos/#{user}/#{repo}/issues/comments", params)
      end
      return response unless block_given?
      response.each { |el| yield el }
    end
    alias :all :list

    # Get a single comment
    #
    # = Examples
    #  github = Github.new
    #  github.issues.comments.find 'user-name', 'repo-name', 'comment-id'
    #
    def get(user_name, repo_name, comment_id, params={})
      set :user => user_name, :repo => repo_name
      assert_presence_of user, repo, comment_id
      normalize! params

      get_request("/repos/#{user}/#{repo}/issues/comments/#{comment_id}", params)
    end
    alias :find :get

    # Create a comment
    #
    # = Inputs
    #  <tt>:body</tt> Required string
    #
    # = Examples
    #  github = Github.new
    #  github.issues.comments.create 'user-name', 'repo-name', 'issue-id',
    #     'body': 'a new comment'
    #
    def create(user_name, repo_name, issue_id, params={})
      set :user => user_name, :repo => repo_name
      assert_presence_of user, repo, issue_id

      normalize! params
      filter! VALID_ISSUE_COMMENT_PARAM_NAME, params
      assert_required_keys(%w[ body ], params)

      post_request("/repos/#{user}/#{repo}/issues/#{issue_id}/comments", params)
    end

    # Edit a comment
    #
    # = Inputs
    #  <tt>:body</tt> Required string
    #
    # = Examples
    #  github = Github.new
    #  github.issues.comments.edit 'user-name', 'repo-name', 'comment-id',
    #     'body': 'a new comment'
    #
    def edit(user_name, repo_name, comment_id, params={})
      set :user => user_name, :repo => repo_name
      assert_presence_of user, repo, comment_id

      normalize! params
      filter! VALID_ISSUE_COMMENT_PARAM_NAME, params
      assert_required_keys(%w[ body ], params)

      patch_request("/repos/#{user}/#{repo}/issues/comments/#{comment_id}", params)
    end

    # Delete a comment
    #
    # = Examples
    #  github = Github.new
    #  github.issues.comments.delete 'user-name', 'repo-name', 'comment-id'
    #
    def delete(user_name, repo_name, comment_id, params={})
      set :user => user_name, :repo => repo_name
      assert_presence_of user, repo, comment_id
      normalize! params

      delete_request("/repos/#{user}/#{repo}/issues/comments/#{comment_id}", params)
    end

  end # Issues::Comments
end # Github
