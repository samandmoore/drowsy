Features to add:
- [x] save
- [x] save!
- [x] update
- [x] update!
- [x] destroy
- [x] find
- [x] where
- [x] all
- [x] has_one
- [x] association builder methods (build_ and association.build)
- [x] callbacks
- [x] associations
- [x] ignore unknown attributes
- [ ] attribute dirty tracking
- [x] add .scope behavior
- [ ] add http failure fallback behavior
- [ ] semian integration/adapter
- [x] add Model#${http_method}
- [x] add Model.${http_method}

**Examples of Model#${http_method} and Model.${http_method}**
The class methods should be chainable on Relations and available
on the class itself.
```
# PUT /users/123/deactivate
User.new(id: 123).put(:deactivate, reason: 'too much nagging')

# GET /users/popular?page=2
User.get(:popular, page: 2)

# GET /posts/popular?commented=true&page=2
Post.where(commented: true, page: 2).get(:popular)

# GET /popular_users?page=2
User.get('/popular_users', page: 2)

# symbols are added as segments on the baseline uri_template
# strings are treated as replacement uri_templates
```
