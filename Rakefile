ENV['version']            ||= 'dev'
ENV['tarball_name']       ||= "pe-demo-#{ENV['version']}"
ENV['platform_tar_flags'] ||= %x{uname}.chomp == 'Darwin' ? '--disable-copyfile' : ''
ENV['project_dir']        ||= File.dirname(__FILE__)

desc "Build the artifact version of this project"
task :default => :tarball

task :tarball => "build/#{ENV['tarball_name']}.tar.gz" do
  puts "tarball task complete"
end

desc "Clean up the build directory and any artifacts"
task :clean do
  rm_rf "build"
end

file "build/#{ENV['tarball_name']}.tar.gz" do
  mkdir_p 'build'
  sh "echo #{ENV['version']} > VERSION"
  project_dir_name = File.basename(ENV['project_dir'])

  Dir.chdir(File.dirname(ENV['project_dir'])) do
    tarflags = [
      ENV['platform_tar_flags'],
      tar_transform_flags(project_dir_name, ENV['tarball_name']),
      '--exclude .git',
      '--exclude .gitignore',
      '--exclude .gitkeep',
      '--exclude .pe_build',
      '--exclude .vagrant',
      '--exclude .files',
      "--exclude '#{project_dir_name}/.librarian'",
      "--exclude '#{project_dir_name}/.tmp'",
      "--exclude '#{project_dir_name}/.gitignore'",
      "--exclude '#{project_dir_name}/build'",
      "--exclude '#{project_dir_name}/build/*'",
      "--exclude '#{project_dir_name}/Rakefile'",
      "--exclude '#{project_dir_name}/Gemfile'",
      "--exclude '#{project_dir_name}/Gemfile.lock'",
      "-cvzf #{ENV['tarball_name']}.tar.gz",
      project_dir_name
    ]
    sh "tar #{tarflags.join(' ')}"
    mv "#{ENV['tarball_name']}.tar.gz", "#{project_dir_name}/build"
  end
end

def tar_transform_flags(from, to)
  case %x{uname}.chomp
  when 'Darwin'
    "-s /#{from}/#{to}/"
  else
    "--transform='s/#{from}/#{to}/'"
  end
end
