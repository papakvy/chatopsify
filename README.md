# Chatopsify

![Gem](https://img.shields.io/gem/v/chatopsify?color=%25234cc61f&label=Gem%20version&logo=ruby&logoColor=red)
![Gem](https://img.shields.io/gem/dt/chatopsify?color=%2330c754&label=Downloads&logo=rubygems&logoColor=red)
[![Rubocop Lint](https://github.com/papakvy/chatopsify/actions/workflows/run_rubocop.yml/badge.svg?branch=main)](https://github.com/papakvy/chatopsify/actions/workflows/run_rubocop.yml)
<!-- ![GitHub Workflow Status](https://img.shields.io/github/workflow/status/rs-phunt/Chatopsify/Tests%20%F0%9F%A7%AA?label=Tests&logo=github)
![GitHub Workflow Status](https://img.shields.io/github/workflow/status/rs-phunt/Chatopsify/Rubocop%20Lint?label=Rubocop&logo=github) -->

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

### Using ENV (or `.env`)

```bash
export CHATOPS_URI='your_chatops_uri'
export CHATOPS_API_KEY='your_chatops_api_key'
export CHATOPS_CHANNEL_ID='your_channel_id'
```

### Using `config/deploy`

```ruby
# config/deploy.rb
...
set :chatops_uri, 'your_chatops_uri'
set :chatops_api_key, 'your_chatops_api_key'
set :chatops_channel_id, 'your_channel_id'
...
```

### Copyright

©rs-phunt
