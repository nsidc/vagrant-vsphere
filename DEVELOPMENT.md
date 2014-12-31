### Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your RuboCop-compliant and test-passing changes (`git commit -am 'Add
   some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

### Versioning

This plugin follows the principles of
[Semantic Versioning 2.0.0](http://semver.org/).

### Unit Tests

Please run the unit tests to verify your changes. To do this simply run `rake`.
If you want a quick merge, write a spec that fails before your changes are
applied and that passes after.

If you don't have rake installed, first install [bundler](http://bundler.io/)
and run `bundle install`. Then you can run `bundle exec rake`, even if rake is
still not installed to your `PATH`.

### RuboCop

Please make changes [RuboCop](https://github.com/bbatsov/rubocop)-compliant.

Changes that eliminate rules from
[`.rubocop_todo.yml`](https://github.com/nsidc/vagrant-vsphere/blob/master/.rubocop_todo.yml)
are welcome.

### Travis-CI

[Travis](https://travis-ci.org/nsidc/vagrant-vsphere) will automatically run
RuboCop and the unit tests when you create a new pull request. If there are any
failures, a notification will appear on the pull request. To update your pull
request, simply create a new commit on the branch that fixes the failures, and
push to the branch.

### Development Without Building the Plugin

To test your changes when developing the plugin, you have two main
options. First, you can build and install the plugin from source every time you
make a change:

1. Make changes
2. `rake build`
3. `vagrant plugin install ./pkg/vagrant-vsphere-$VERSION.gem`
4. `vagrant up --provider=vsphere`

Second, you can use Bundler and the Vagrant gem to execute vagrant commands,
saving time as you never have to wait for the plugin to build and install:

1. Make changes
2. `bundle exec vagrant up --provider=vsphere`

This method uses the version of Vagrant specified in
[`Gemfile`](https://github.com/nsidc/vagrant-vsphere/blob/master/Gemfile). It
will also cause Bundler and Vagrant to output warnings every time you run
`bundle exec vagrant`, because `Gemfile` lists **vagrant-vsphere** twice (once
with `gemspec` and another time in the `group :plugins` block), and Vagrant
prefers to be run from the official installer rather than through the gem.

Despite those warning messages, this is the
[officially recommended](https://docs.vagrantup.com/v2/plugins/development-basics.html)
method for Vagrant plugin development.
