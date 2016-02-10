# Gemfile.lock to JSON Converter
This script searches Github's API for any Gemfile.lock files under your organization's account. It then transforms the Gemfile.lock data into a nicely formatted JSON object. Now you have the building blocks for a sweet Gemfile auditing tool, or maybe a nice data viz of your organization's application dependencies. Sweet!

NOTE: You'll be restricted to 100 results from Github at this time. If you want to modify to enable paginating through multiple pages of results, knock yourself out. Information on how to do that can be found [here](https://developer.github.com/guides/traversing-with-pagination/). Github's API only returns up to 100 results per page, but they tell you how many result pages they're responding with.
