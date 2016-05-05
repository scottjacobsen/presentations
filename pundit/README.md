<div id="table-of-contents">
<h2>Table of Contents</h2>
<div id="text-table-of-contents">
<ul>
<li><a href="#orgheadline1">1. Authorization with Pundit</a></li>
<li><a href="#orgheadline2">2. Authentication vs Authorization</a></li>
<li><a href="#orgheadline3">3. A typical rails #update action</a></li>
<li><a href="#orgheadline4">4. ActiveRecord scopes to the rescue!</a></li>
<li><a href="#orgheadline5">5. Of course you wrote tests for this</a></li>
<li><a href="#orgheadline6">6. Oops</a></li>
<li><a href="#orgheadline7">7. Victory?</a></li>
<li><a href="#orgheadline8">8. The site needs moderators</a></li>
<li><a href="#orgheadline9">9. Don't forget the tests</a></li>
<li><a href="#orgheadline10">10. Oops</a></li>
<li><a href="#orgheadline11">11. Victory?</a></li>
<li><a href="#orgheadline12">12. The path to victory</a></li>
<li><a href="#orgheadline13">13. One reusable place</a></li>
<li><a href="#orgheadline14">14. Add a one liner to the controller</a></li>
<li><a href="#orgheadline15">15. Reuse the logic in the view</a></li>
<li><a href="#orgheadline16">16. Better tests</a></li>
<li><a href="#orgheadline17">17. Better tests</a></li>
<li><a href="#orgheadline18">18. Victory?</a></li>
<li><a href="#orgheadline19">19. What about Pundit?</a></li>
<li><a href="#orgheadline20">20. Pundit in controllers</a></li>
<li><a href="#orgheadline21">21. Pundit in controllers: #authorize</a></li>
<li><a href="#orgheadline22">22. Pundit in controllers: ::verify_authorized</a></li>
<li><a href="#orgheadline23">23. Pundit in controllers: Handling exceptions</a></li>
<li><a href="#orgheadline24">24. Pundit in views</a></li>
<li><a href="#orgheadline25">25. Pundit with strong parameters</a></li>
<li><a href="#orgheadline26">26. Pundit and scopes</a></li>
<li><a href="#orgheadline27">27. Victory?</a></li>
</ul>
</div>
</div>

# Authorization with Pundit<a id="orgheadline1"></a>

Scott Jacobsen

<https://github.com/scottjacobsen/>

# Authentication vs Authorization<a id="orgheadline2"></a>

Authentication -> You are who you say you are.

-   User name/password
-   Connect with Facebook, etc.

Authorization -> You are allowed to do something.

-   You are authorized to create/delete/etc a record.

# A typical rails #update action<a id="orgheadline3"></a>

```ruby
    def update
      @comment = Comment.find params[:id]
      if @comment.update comment_params
        redirect_to @comment, notice: "Success!"
      else
        render :edit
      end
    end
```

Whats wrong with this method?

![img](./bad-method.jpg)

# ActiveRecord scopes to the rescue!<a id="orgheadline4"></a>

Use ActiveRecord scopes as an authorization mechanism.

```ruby
    def update
      # Scope the comments to the current user
      @comment = current_user.comments.find params[:id]
      if @comment.update comment_params
        redirect_to @comment, notice: "Success!"
      else
        render :edit
      end
    end
```

![img](./no-droids.jpg)

# Of course you wrote tests for this<a id="orgheadline5"></a>

```ruby
    test "update raises if current_user isn't owner" do
      #...
    end

    test "owner updates" do
      #...
    end
```

![img](./tests.jpg)

# Oops<a id="orgheadline6"></a>

Don't forget the view.

```ruby
    - if current_user == @comment.user
      = link_to "Edit", edit_comment_path @comment
```

![img](./oops1.jpg)

# Victory?<a id="orgheadline7"></a>

The internet:

![img](./scum.jpg)

# The site needs moderators<a id="orgheadline8"></a>

```ruby
    def update
      # Moderators can edit all the things
      # otherwise scope to the user. Sigh...
      @comment = if current_user.moderator?
                   Comment.find params[:id]
                 else
                   current_user.comments.find params[:id]
                 end
      if @comment.update comment_params
        redirect_to @comment, notice: "Success!"
      else
        render :edit
      end
    end
```

![img](./moderator.jpg)

# Don't forget the tests<a id="orgheadline9"></a>

```ruby
    test "moderator updates" do
      #...
    end

    test "update raises if current_user isn't owner or moderator" do
      #...
    end

    test "owner updates" do
      #...
    end
```
![img](./tests.jpg)

# Oops<a id="orgheadline10"></a>

Don't forget the view.

```ruby
    - if current_user.moderator? || current_user == @comment.user
      = link_to "Edit", edit_comment_path @comment
```

![img](./oops1.jpg)

# Victory?<a id="orgheadline11"></a>

-   Authorization code is duplicated and scattered around views
    controllers
-   An explosion of **slow** controller tests
-   It is easy to forget to add authorization code in other actions
    (#destroy, #create, etc)

![img](./victory.jpeg)

# The path to victory<a id="orgheadline12"></a>

-   Move authorization logic to one reusable place
-   Handle authorization with a one liner in the controller actions
-   Leverage Rails exception handling
-   Make it difficult to forget adding authorization logic.
-   Better tests

![img](./path-to-victory.jpg)

# One reusable place<a id="orgheadline13"></a>

-   Create a PORO to encapsulate the authorization logic.
-   In general - Create one policy object per model
```ruby
    # In app/policies/comment_policy.rb
    class CommentPolicy
      def initialize(current_user, comment)
        @user = current_user
        @comment = comment
      end

      def update?
        @user == comment.user || @user.moderator?
      end
      alias edit? update?

      def create?
        # TODO
      end
      alias new? create?

      def destroy?
        # TODO
      end

      def show?
        # TODO
      end

      def index?
        # TODO
      end
    end
```

# Add a one liner to the controller<a id="orgheadline14"></a>

```ruby
    def update
      @comment = Comment.find params[:id]
      CommentPolicy.new(current_user, @comment).update? || raise(UnauthorizedError)
      if @comment.update comment_params
        redirect_to @comment, notice: "Success!"
      else
        render :edit
      end
    end
```

# Reuse the logic in the view<a id="orgheadline15"></a>

    - if CommentPolicy.new(current_user, @comment).update?
      = link_to "Edit", edit_comment_path(@comment)

# Better tests<a id="orgheadline16"></a>

Unit test authorization logic in isolation, not through the
controller.

Unlike a controller test this test is very fast - it does not touch
the database, render views, etc.

```ruby
    class CommentPolicyTest < ActiveSupport::TestCase
      test "#update? allows moderators" do
        moderator = User.new moderator: true
        comment = Comment.new
        assert CommentPolicy.new(moderator, comment).update?
      end

      test "#update? allows owner" do
        user = User.new
        comment = Comment.new user: user
        assert CommentPolicy.new(user, comment).update?
      end

      test "#update? does not allow other users" do
        refute CommentPolicy.new(User.new, Comment.new).update?
      end
    end
```
![img](./fast.jpg)

# Better tests<a id="orgheadline17"></a>

The controller test does not need to test the authorization logic -
only that authorization is done.

If the authorization logic changes there are no changes to the
controller test.

```ruby
    class CommentsControllerTest < ActionController::TestCase
      test "#update" do
        CommentPolicy.any_instance.expects(:update?).returns true
        #...
      end

      test "#update raises when unauthorized" do
        CommentPolicy.any_instance.expects(:update?).returns false

        assert_raise UnauthorizedError do
          #...
        end
      end
    end
```

# Victory?<a id="orgheadline18"></a>

We are close.

![img](./near-victory.jpg)

# What about Pundit?<a id="orgheadline19"></a>

Pundit simply provides a few helper methods that make it easy to use
policies in controllers and views.

![img](./pundit-helper.jpg)

# Pundit in controllers<a id="orgheadline20"></a>

Mix Pundit into your application controller

```ruby
    class ApplicationController < ActionController::Base
      include Pundit
      #...
    end
```
# Pundit in controllers: #authorize<a id="orgheadline21"></a>

Pundit provides the #authorize helper method to authorize actions.

\#authorize figures out which policy class to use, and which policy
method to call.

\#authorize gets the user (by default) by calling current_user.

If authorization fails Pundit::NotAuthorizedError is raised.

```ruby
    def update
      @comment = Comment.find params[:id]
      authorize @comment
      if @comment.update comment_params
        redirect_to @comment, notice: "Success!"
      else
        render :edit
      end
    end
```

# Pundit in controllers: ::verify_authorized

The ::verify_authorized class method will cause actions to raise
Pundit::AuthorizationNotPerformedError if #authorize is not called in
a controller action.

```ruby
    class CommentsController < ApplicationController
      after_action :verify_authorized

      # Update properly authorizes
      def update
        @comment = Comment.find params[:id]
        authorize @comment
        if @comment.update comment_params
          redirect_to @comment, notice: "Success!"
        else
          render :edit
        end
      end

      # Raises Pundit::AuthorizationNotPerformedError, but the object is
      # still destroyed!
      def destroy
        @comment = Comment.find params[:id]
        @comment.destroy
      end

      # Pundit#skip_authorization to skip authorization
      def edit
        @comment = Comment.find_by_id params[:id]
        if @comment
          authorize @comment
        else
          skip_authorization
          redirect_to :index
        end
      end
    end
```
# Pundit in controllers: Handling exceptions<a id="orgheadline23"></a>

Use Rail's #rescue_from to handle pundit exceptions.

```ruby
    class ApplicationController < ActionController::Base
      include Pundit

      rescue_from Pundit::NotAuthorizedError do |_|
        raise ActionController::RoutingError, "Not Authorized"
      end
    end
```
![img](./handle-exceptions.jpg)

# Pundit in views<a id="orgheadline24"></a>

Use Pundit's #policy method to conditionally render view elements.

```ruby
    - if policy(@comment).edit?
      = link_to "Edit", edit_comment_path(@comment)
```
# Pundit with strong parameters<a id="orgheadline25"></a>

Parameters used by an action often vary based on authorization logic.

Simply add a #permitted_attributes method to the policy class.

```ruby
    class CommentPolicy
      def permitted_attributes
        if @user.moderator?
          [:comment_text, :featured]
        else
          [:comment_text]
        end
      end
    end
```

Use the #permitted_attributes helper in the controller

```ruby
    def update
      @comment = Comment.find params[:id]
      authorize @comment
      if @comment.update permitted_attributes(@comment)
        redirect_to @comment, notice: "Success!"
      else
        render :edit
      end
    end
```

# Pundit and scopes<a id="orgheadline26"></a>

Pundit has helpers that allow you scope active record queries to
record the user has permission to view.

```ruby
    class CommentsController
      def index
        @comments = policy_scope(Comment)
      end
    end
```

![img](./scoping.jpg)

# Victory?<a id="orgheadline27"></a>

![img](./victory.jpg)

<https://github.com/elabs/pundit>
