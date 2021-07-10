## Improve Blog Formatting
- needs a Tailwind CSS makeover


## Add comment model

- generate comment model
```
rails g model comment body:text edit_history:text commentable_id:integer commentable_type:string user:references reply:boolean comment_number:integer
```
- update migration
```
t.text :edit_history, default: ''
t.boolearn :reaply, default: false
```
## Add migration for adding number comments to user
- generate migration
```
rails g migration add_number_of_comments_to_user number_of_comments:integer 
```
- update migration
```
add_column :users, :number_of_comments, :integer, default: 0
```
## Update comment model
```ruby
belongs_to: user  # should be automatic 
before_create :set_comment_number
# not using rich text (see video: https://www.youtube.com/watch?v=YMFL0U1bNSM 12:24)

# polymorphic comments
belongs_do :commentable, polymorphic: true
has_many: comments, as :commentable, dependent: :destroy

private 
def set_comment_number
  # users total number of comments created
  self.comment_number = user.comment_created
end
```
## Update user model
```ruby
has_many :comments

def comment_created
  number_of_comments = number_of_comments + 1
  save
  number_of_comments
end
```

## Update post model
```ruby
has_many :comments, as: :commentable


```



## Add social logins for comments
- to figure out

## Add discard gem 
- use soft delete everywhere
- add `dependent: :destroy`



