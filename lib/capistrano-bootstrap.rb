require 'fileutils'
require 'versionomy'

class CapistranoBootstrap
  class << self
    # Update configuration repository every day
    UPDATE_INTERVAL = 60 * 60 * 24

    def invoke(repository, args = {})
      args[:config_dir] ||= "config/capistrano"
      args[:target_path] ||= "config/.config_repo"

      if !File.directory? args[:target_path]
        clone_repository(repository, "./config/.config_repo")
      elsif repository_needs_update?(args[:target_path])
        update_repository(args[:target_path])
      end

      tags = get_repository_tags(args[:target_path]).map { |x| Versionomy.parse(x) }.sort
      if configuration_needs_update?(args[:target_path], tags)
        update_capistrano_configuration(args[:target_path], args[:config_dir], tags)
      end
    end

private

    def configuration_needs_update?(target_path, tags)
      return true if !ENV["CAPBOOTSTRAP_FORCE"].nil?
      current_tag = get_current_tag(target_path)
      return true if current_tag.nil?
      current_tag < tags.last
    end

    # Checks out the latest configuration tag and copies all files to the configuration
    # directory.
    def update_capistrano_configuration(target_path, config_dir, tags)
      update_to = tags.last
      tell("About to update capistrano configuration to tag '#{update_to}'")

      in_dir_do(target_path) do
        execute_command("git checkout #{update_to}")
      end
      set_current_tag(target_path, update_to)
      tell("Configuration updated to '#{update_to}'")

      tell("Copying updated configuration to '#{config_dir}'")
      execute_command("cp -rf #{target_path}/* #{config_dir}")

      write_gitignore(target_path, config_dir)

      tell("Finished updating configuration at '#{config_dir}' to '#{update_to}'")
    end

    # Writes a .gitignore file which ignores all files copied from the capistrano
    # configuration repository.
    def write_gitignore(target_path, config_dir)
      tell("Updating #{config_dir}/.gitignore")
      files = in_dir_do(target_path) { Dir.glob("*") }
      files.push(".gitignore")
      in_dir_do(config_dir) do
        File.open(".gitignore", 'w+') { |f| f.write(files.join("\n")) }
      end
    end

    # The file that contains the currently checked out tag (that is, the last tag
    # whose contents where copied to the configuration directory)
    def tag_file(target_path)
      "#{target_path}/.CAPBOOTSTRAP_TAG"
    end

    def get_current_tag(target_path)
      dir = tag_file(target_path)
      return nil if !File.exists?(dir)
      lines = File.read(dir).split("\n")
      return nil if lines.length < 1
      Versionomy.parse(lines.first)
    end

    def set_current_tag(target_path, tag)
      File.open(tag_file(target_path), 'w+') { |f| f.write(tag) }
    end

    # Returns an array of tags specified for the cloned configuration repository
    def get_repository_tags(target_path)
      in_dir_do(target_path) do
        out = execute_command("git tag")
        raise "Repository in path #{target_path} is not a valid Git repository" if $? != 0

        tags = out.split("\n")
        raise "Repository in path #{target_path} does not contain any tags!" if tags.length < 1

        tags
      end
    end

    def clone_repository(repository, target_path)
      tell "Cloning repository #{repository} to #{target_path}"
      execute_command("git clone #{repository} #{target_path}")
    end

    # Determines if the repository needs to be updated by checking when it was last
    # touched (by the #update_repository method)
    def repository_needs_update?(target_path)
      return true if !ENV["CAPBOOTSTRAP_FORCE"].nil?
      (Time.now - File.mtime(target_path)) > UPDATE_INTERVAL
    end

    # Pull the latest contents (including tags) for the repository
    def update_repository(target_path)
      in_dir_do(target_path) do
        tell "Updating local configuration repository at '#{target_path}'"
        execute_command("git checkout master")
        execute_command("git pull origin master --tags")

        head = execute_command("git rev-parse HEAD")[0,8]
        tell("Updated local configuration repository to #{head}")
      end
      execute_command("touch #{target_path}")
    end

    def tell(text)
      puts "[CapBootstrap]: #{text}"
    end

    # Switches to the specified directory, executes the given block and then
    # switches the working directory back to where it was before.
    def in_dir_do(target_path, &block)
      cwd = Dir.pwd
      Dir.chdir(target_path)
      out = block.call
      Dir.chdir(cwd)
      out
    end

    # Executes the given shell command in the current working directory, and throws an
    # exception in case the command failed (exit status != 0)
    def execute_command(command)
      out = `#{command} 2>&1`
      raise "There was an error executing '#{command}'. Output: \n #{out} \n" if $? != 0
      out
    end
  end
end
