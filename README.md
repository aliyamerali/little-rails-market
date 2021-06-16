# Little Esty Shop

## About this Project
"Little Esty Shop" is a group project that requires students to build a fictitious e-commerce platform where merchants and admins can manage inventory and fulfill customer invoices. This repo builds upon the core functionality defined in these [user stories](./doc/user_stories.md) to add on a bulk-discount feature, as defined in these [user stories](https://backend.turing.edu/module2/projects/bulk_discounts).

### Bulk Discount Functionality
Timeframe: 6 days   
Heroku: [Little Rails Market](https://little-rails-market.herokuapp.com/)  
Contributor: 
- Aliya Merali  
   [Github](https://github.com/aliyamerali) | [LinkedIn](https://www.linkedin.com/in/aliyamerali/)

### Core Functionality
Timeframe: 9 days   
Heroku: [Little Rails Shop](https://little-rails-shop.herokuapp.com/)    
Contributors: 
- Lawrence Whalen  
   [Github](https://github.com/LawrenceWhalen) | [LinkedIn](https://www.linkedin.com/in/lawrence-whalen-15996220a/)
- Aliya Merali  
   [Github](https://github.com/aliyamerali) | [LinkedIn](https://www.linkedin.com/in/aliyamerali/)
- Molly Krumholz  
   [Github](https://github.com/mkrumholz) | [LinkedIn](https://www.linkedin.com/in/mkrumholz/)
- Sidarth Bagawandoss  
   [Github](https://github.com/Sidarth20) | [LinkedIn](https://www.linkedin.com/in/sidarth-bagawandoss-12220644/)

## Learning Goals
 - Practice designing a normalized database schema and defining model relationships
 - Utilize advanced routing techniques including namespacing to organize and group like functionality together
 - Utilize advanced active record techniques to perform complex database queries
 - Practice consuming a public API while utilizing POROs as a way to apply OOP principles to organize code

## Schema
![Little Esty Shop Schema (1)](https://user-images.githubusercontent.com/5446926/121786297-3590d700-cb7c-11eb-9afa-4d68fe64db5b.png)


## Built With
- Ruby 2.7.2
- Rails 5.2.6
- ActiveRecord
- SQL
- RSpec
- Capybara
- Factory Bot
- GitHub API
- Nager.date API

## Important Gems(Libraries):
* [rspec-rails](https://github.com/rspec/rspec-rails)
* [capybara](https://github.com/teamcapybara/capybara)
* [shoulda-matchers](https://github.com/thoughtbot/shoulda-matchers)
* [faraday](https://github.com/lostisland/faraday)
* [factory_bot_rails](https://github.com/thoughtbot/factory_bot_rails)
* [simplecov](https://github.com/simplecov-ruby/simplecov)
* [orderly](https://github.com/simplecov-ruby/simplecov)

## Getting Started
1. Fork and clone the repo
2. Install any missing gems from gem file
3. Install gem packages with `bundle install`
4. Run `$ rails db:{create,migrate}`
5. Run `$ rake csv_load:all`
6. From your terminal run `$ rails s` and navigate to http://localhost:3000/ in your browser to navigate the app

## Testing
* RSpec and Capybara were used for unit and integration testing and project development adhered to TDD principles.
* Simplecov was used to track total test coverage.
* To run our test suite, RSpec, enter `$ bundle exec rspec` in the terminal.
* To see a coverage report enter `$ open coverage/index.html`

## Additonal References
- [Base Repository](https://github.com/turingschool-examples/little-esty-shop) used for Turing's Backend Module 2.
- [Github API Documentation](https://docs.github.com/en/rest)
- [Nager.date API Documentation](https://date.nager.at/)
