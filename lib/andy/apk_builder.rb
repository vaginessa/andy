require 'digest/sha1'

class Andy::ApkBuilder
  def build(repo, project_id, project, path, sdk_dir)
    repo_hash = ::Digest::SHA1.hexdigest(project['repo']['url'])
    dir = ::File.expand_path("tmp/repos/#{project_id}/#{repo_hash}#{path}", settings.root)
    ::FileUtils.rm_rf(dir) if File.exist? dir
    ::FileUtils.mkdir_p(dir)
    repo.checkout(path, dir)
    put_local_properties(dir, sdk_dir)
    orig_dir = Dir.pwd
    Dir.chdir(dir)
    java_opt = "_JAVA_OPTIONS='-Dfile.encoding=UTF-8'"
    result = `#{java_opt} ant debug && #{java_opt} ant release`
    Dir.chdir(orig_dir)
    result
  end

  def put_local_properties(dir, sdk_dir)
    open("#{dir}/local.properties", 'w') do |file|
      file.puts "sdk.dir=#{sdk_dir}"
    end
  end
end