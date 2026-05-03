<%= ENV['PR_TITLE'] %>

## Changelog

<% commits.each do |commit| -%>

- <%= commit.short_id %> <%= commit.subject %>
  <% end -%>
