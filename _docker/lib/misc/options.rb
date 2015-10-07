class Options
  def self.parse(args)
    tasks = {}

    opts_parse = OptionParser.new do |opts|
      opts.banner = 'Usage: control.rb [options]'
      opts.separator 'Specific options:'

      docker_message = "Docker client connection info (i.e. tcp://example.com:1000). "\
                       "DOCKER_HOST used if parameter not provided"
      opts.on('-d', '--docker CONNECTION_INFO', String, docker_message) do |d|
        tasks[:docker] = d
      end

      opts.on('-r', '--restart', 'Restart the containers') do |r|
        tasks[:decrypt] = true
        tasks[:set_ports] = true
        tasks[:kill_all] = true
        tasks[:supporting_services] = %w(-d elasticsearch mysql searchisko searchiskoconfigure)
      end

      opts.on('-b', '--build', 'Build the containers') do |b|
        tasks[:decrypt] = true
        tasks[:set_ports] = true
        tasks[:build] = true
      end

      opts.on('-g', '--generate', 'Run awestruct (clean gen)') do |r|
        tasks[:decrypt] = true
        tasks[:awestruct_command_args] = ['--no-deps', '--rm', '--service-ports', 'awestruct', 'rake clean gen[docker]']
      end

      opts.on('-p', '--preview', 'Run awestruct (clean preview)') do |r|
        tasks[:decrypt] = true
        tasks[:awestruct_command_args] = ['--no-deps', '--rm', '--service-ports', 'awestruct', 'rake git_setup clean preview[docker]']
      end

      opts.on('-u', '--drupal', 'Start up and enable drupal') do |u|
        tasks[:drupal] = true
      end

      opts.on('--stage-pr PR_NUMBER', Integer, 'build for PR Staging') do |pr|
        tasks[:awestruct_command_args] = ["--no-deps", "--rm", "--service-ports", "awestruct", "bundle exec rake create_pr_dirs[docker-pr,build,#{pr}] clean deploy[staging_docker_pr]"]
        tasks[:kill_all] = true
        tasks[:supporting_services] = %w(-d elasticsearch mysql searchisko searchiskoconfigure)
      end

      opts.on('--run-the-stack', 'build, restart and preview') do |rts|
        tasks[:decrypt] = true
        tasks[:set_ports] = true
        tasks[:build] = true
        tasks[:kill_all] = true
        tasks[:supporting_services] = %w(-d elasticsearch mysql searchisko searchiskoconfigure)
        tasks[:awestruct_command_args] = ['--no-deps', '--rm', '--service-ports', 'awestruct', 'rake git_setup clean preview[docker]']
      end

      # No argument, shows at tail.  This will print an options summary.
      opts.on_tail('-h', '--help', 'Show this message') do
        puts opts
        exit
      end
    end

    opts_parse.parse! args
    tasks
  end
end