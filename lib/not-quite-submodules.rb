require 'fileutils'
require 'versionomy'
require 'tmpdir'
require 'digest/sha1'

class NotQuiteSubmodules
  class << self
    # Update configuration repository every day
    DEFAULT_UPDATE_INTERVAL = 60 * 60 * 24

    def initialize(repository, target_path, args = {})
      args[:target_path] = target_path
      @update_interval = args[:update_interval] || DEFAULT_UPDATE_INTERVAL
      @force_update_to = args[:force_update_to]

      if args[:temp_path].nil?
        tmp_name = (Digest::SHA1.hexdigest repository)
        args[:temp_path] = "#{Dir.tmpdir}/#{tmp_name[0..8]}"
      end

      check_temporary_repository(args[:temp_path])

      if !File.directory? args[:temp_path]
        clone_repository(repository, args[:temp_path])
      elsif repository_needs_update?(args[:temp_path])
        update_repository(args[:temp_path])
      end

      tags = get_repository_tags(args[:temp_path]).map { |x| Versionomy.parse(x) }.sort
      if configuration_needs_update?(args[:target_path], tags)
        update_target_path(args[:temp_path], args[:target_path], tags)
      end
    end

private

    def configuration_needs_update?(target_path, tags)
      return true if !ENV["FORCE_UPDATE"].nil? || @force_update_to
      current_tag = get_current_tag(target_path)
      tell("Currently checked out tag is #{current_tag}, latest tag is #{tags.last}")
      return true if current_tag.nil?
      current_tag < tags.last
    end

    # Checks out the latest tag and copies all files to the target path.
    def update_target_path(temp_path, target_path, tags)
      update_to = @force_update_to || tags.last
      tell("About to update target path to tag '#{update_to}'")

      in_dir_do(temp_path) do
        execute_command("git reset --hard #{update_to}")
      end
      set_current_tag(target_path, update_to) if !@force_update_to
      tell("Updated to '#{update_to}'")

      tell("Copying updated files to '#{target_path}'")
      execute_command("cp -rf #{temp_path}/* #{target_path}")

      write_gitignore(temp_path, target_path)

      tell("Finished updating '#{target_path}' to '#{update_to}'")
    end

    # Writes a .gitignore file which ignores all files copied from the repository.
    def write_gitignore(temp_path, target_path)
      tell("Updating #{target_path}/.gitignore")
      files = in_dir_do(temp_path) { Dir.glob("*") }
      files.push(".gitignore")
      files.push(".CURRENT_TAG")
      in_dir_do(target_path) do
        File.open(".gitignore", 'w+') { |f| f.write(files.join("\n")) }
      end
    end

    # The file that contains the currently checked out tag (that is, the last tag
    # whose contents where copied to the configuration directory)
    def tag_file(target_path)
      "#{target_path}/.CURRENT_TAG"
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
    def get_repository_tags(temp_path)
      in_dir_do(temp_path) do
        out = execute_command("git tag")
        raise "Repository in path #{temp_path} is not a valid Git repository" if $? != 0

        tags = out.split("\n")
        raise "Repository in path #{temp_path} does not contain any tags!" if tags.length < 1

        tags
      end
    end

    def clone_repository(repository, temp_path)
      tell "Cloning repository #{repository} to #{temp_path}"
      execute_command("git clone #{repository} #{temp_path}")
    end

    # Determines if the repository needs to be updated by checking when it was last
    # touched (by the #update_repository method)
    def repository_needs_update?(temp_path)
      return true if !ENV["FORCE_UPDATE"].nil?
      (Time.now - File.mtime(temp_path)) > @update_interval
    end

    # Pull the latest contents (including tags) for the repository
    def update_repository(temp_path)
      in_dir_do(temp_path) do
        tell "Updating local configuration repository at '#{temp_path}'"
        execute_command("git checkout master")
        execute_command("git fetch")
        execute_command("git fetch --tags")
        execute_command("git reset --hard origin/master")

        head = execute_command("git rev-parse HEAD")[0,8]
        tell("Updated local configuration repository to #{head}")
      end
      execute_command("touch #{temp_path}")
    end

    # Since we're using a system temp directory by default, parts of the repository
    # may be deleted as part of OS cleanup (at least this seems to be the case with
    # OSX, since the repository became randomly invalid after standby/reboot). Therefore,
    # we need to check if the repository is still valid, and delete it if it is not.
    def check_temporary_repository(temp_path)
      return if !File.directory? temp_path
      in_dir_do(temp_path) do
        `git status`
        if $? != 0
          tell "Repository at temporary path seems to be invalid. Deleting it."
          FileUtils.rm_r temp_path
        end
      end
    end

    def tell(text)
      if @wrote_banner.nil?
        puts "[NotQuiteSubmodules]"
        @wrote_banner = true
      end

      puts "\t=> #{text}"
    end

    # Switches to the specified directory, executes the given block and then
    # switches the working directory back to where it was before.
    def in_dir_do(temp_path, &block)
      cwd = Dir.pwd
      Dir.chdir(temp_path)
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
