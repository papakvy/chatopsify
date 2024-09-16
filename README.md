# Chatopsify

![Gem](https://img.shields.io/gem/v/Chatopsify?color=%234cc61f&label=Gem%20version&logo=ruby&logoColor=red)
![Gem](https://img.shields.io/gem/dt/Chatopsify?color=%2330c754&label=Downloads&logo=rubygems&logoColor=red)
![GitHub Workflow Status](https://img.shields.io/github/workflow/status/rs-phunt/Chatopsify/Tests%20%F0%9F%A7%AA?label=Tests&logo=github)
![GitHub Workflow Status](https://img.shields.io/github/workflow/status/rs-phunt/Chatopsify/Rubocop%20Lint?label=Rubocop&logo=github)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'chatopsify', require: false
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install chatopsify

## Usage

Require the gem in your `Capfile`:

    require 'capistrano/chatopsify'

## Configuration

### Puts `CHATOPS_API_KEY` into your ENV

- Export to your `bash`: `export CHATOPS_API_KEY=xxx`

- Add to `.env` if you're using `dotenv` gem


### Puts `CHATOPS_CHANNEL_ID` into your ENV or custom in `config/deploy`

```ruby
# config/deploy.rb
...
set :chatops_channel_id, 'xxx'
...
```

### Copyright

©rs-phunt
