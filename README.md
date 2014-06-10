#OmniAuth Alephx Strategy

## Installation

Add this line to your application's Gemfile:

    gem 'omniauth-alephx'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install omniauth-alephx

## Usage

Use like any other OmniAuth strategy:

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :alephx, url: 'http://aleph.server.be/X', library: 'usm50'
end
```

Or like in Rails:

```ruby
config.omniauth :alephx,{
  :url => "http://aleph.server.be/X",
  :library => "usm50"
}
```

### Configuration Options

#### Required

OmniAuth CAS requires at least one of the following two configuration options:

  * `url` - Defines the URL of your AlephX server (e.g. `http://example.org:8080/X`)
  * `library` - Defines the name of your aleph user database (e.g. usm50)

#### Optional

Other configuration options:

  * `form` - proc or lambda that returns a rails response object. 
          
```ruby
config.omniauth :alephx,{
  :url => "http://aleph.server.be/X",
  :library => "usm50",
  :form => lambda { |env|
    AlephxSessionController.action(:new).call(env)
  }
}
```
When `form` is not set, options below will be used.
    
  * `title_form` 
  * `label_username`
  * `label_password` 
  * `label_submit`

## Class methods

  * add_filter(&block)
    
    change input parameters

```ruby
OmniAuth::Strategies::Alephx.add_filter do |params|

  unless params['username'].nil?

    #if the 'username' looks like a EAN-13, then strip off the last check digit
    params['username'].strip!
    if params['username'] =~ /^\d{13,}$/
      params['username'] = params['username'][0..-2]
    end

  end
  
end
```

##Author

    Nicolas Franck

