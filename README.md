# Gemfile.lock to JSON Converter
This script searches Github's API for any Gemfile.lock files under your organization's account. It then transforms the Gemfile.lock data into a nicely formatted JSON object. Now you have the building blocks for a sweet Gemfile auditing tool, or maybe a nice data viz of your organization's application dependencies. Sweet!

NOTE: You'll be restricted to 100 results from Github at this time. If you want to modify to enable paginating through multiple pages of results, knock yourself out. Github's API only returns 100 results per page, though.
