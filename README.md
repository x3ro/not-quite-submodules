# not-quite-submodules

This gem can be used to automatically check out and update a git repository pretty much anywhere. I wrote it because I wanted to be able to clone a project repository, and then automatically fetch some deployment capistrano tasks, keeping them up to date whenever I run a `cap` command. But you can use it anywhere else as well, it's not limited to capistrano or even being inside a git repository.



## How it works

not-quite-submodules simply clones the specified repository, checks out the latest tag (by version number!) and copies the content to the specified `config_dir`.

There _must_ be at least one tag in the configuration repository, otherwise the update will fail. The version comparison/ordering is done using the [Versionomy](https://github.com/dazuma/versionomy) gem, for example:

    v1.0 < v1.0.1 < v1.1 < v1.1.1 < ...

For your convenience, not-quite-submodules also generates a `.gitignore` file in the `config_dir` which ignores all content copied from the configuration repository.

By default, capistrano-bootstrap will try to update the configuration repository once every 24 hours. You may force an update by setting the `FORCE_UPDATE` environment variable to a truthy value. From the command line, for example:

    FORCE_UPDATE=1 cap deploy



## How to set up (for capistrano)?

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

    require 'not-quite-submodules'
    NotQuiteSubmodules.initialize(
        "git@github.com:you-on-github/capistrano-configuration.git",
        :target_path => "config/capistrano",
        :temp_path => "config/.config_repo"
    )



## The `#initialize` method

`initialize` is pretty much everything you'll ever see of not-quite-submodules. It takes the repository to be cloned as its first parameter and allows you to specify the following configuration parameters:

* `:target_path` => This is where you'd like the files from the repository to end up in the end.
* `:temp_path` => The directory to which the repository is cloned. Note that this directory is not deleted after the files have been updated so that the entire repository does not need to be cloned again next time. Therefore it might be a good idea to add it to your `.gitignore` file.



## Caveats

* not-quite-submodules does not currently **delete** any files, it only overwrites updated files or creates newly created ones.



## TODO

* Support file deletion




## Boring legal stuff (read: License)

Copyright (C) 2013 Lucas Jenß

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


