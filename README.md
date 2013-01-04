# capistrano-bootstrap

This gem can be used to keep capistrano configuration synchronized between multiple projects. If you have several git repositories in which you are using the same or very similar capistrano configurations, this gem is for you.



## How to set up?

You'll need a new git repository containing your configuration. Lets say you currently use the following directory structure in your projects:

    project/
        Cap
        config/
            capistrano/
                deploy.rb
                util/
                    important.rb
                    stuff.rb
                project.rb
                stages/
                    production.rb
                    staging.rb
        [...]

Let us also assume that everything in the `util/` folder as well as `deploy.rb` is never modified, that is, the project specific configuration resides solely in `stages/` and `project.rb`. You'd now create a new git repository containing the following:

    deploy.rb
    util/
        important.rb
        stuff.rb

Then you'd simply remove these files from your project structure, resulting in:

    project/
        Cap
        config/
            capistrano/
                project.rb
                stages/
                    production.rb
                    staging.rb
        [...]

Now you want to add the following lines to the beginning of your `Cap` file:

    require 'capistrano-bootstrap'
    CapistranoBootstrap.invoke(
        "git@github.com:you-on-github/capistrano-configuration.git",
        :config_dir => "config/capistrano",
        :target_path => "config/.config_repo"
    )

The `invoke` method has the following optional parameters:

* `:config_dir` => Where you would like to have your global capistrano config copied to.
* `:target_path` => The directory to which the configuration repository will be cloned.

The parameter values in the above `invoke` example are the default values.

By default, capistrano-bootstrap will try to update the configuration repository once every 24 hours. You may overwrite that behavior (i.e. force an update) by invoking your capistrano task like this:

    CAPBOOTSTRAP_FORCE=1 cap deploy

For your convenience, capistrano-bootstrap also generates a `.gitignore` file in the `config_dir` which ignores all content copied from the configuration repository.



## How it works

capistrano-bootstrap simply clones the specified repository, checks out the latest tag (by version number!) and copies the content to the specified `config_dir`.

There _must_ be at least one tag in the configuration repository, otherwise the update will fail. The version comparison/ordering is done using the [Versionomy](https://github.com/dazuma/versionomy) gem, for example:

    v1.0 < v1.0.1 < v1.1 < v1.1.1 < ...



## Caveats

* capistrano-bootstrap does not currently **delete** any files, it only overwrites updated files or creates newly created ones.



## TODO

* Write spec
* Support file deletion



## Boring legal stuff (read: License)

Copyright (C) 2013 Lucas Jenß

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


