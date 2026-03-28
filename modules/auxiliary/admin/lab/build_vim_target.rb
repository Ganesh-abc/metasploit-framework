require 'msf/core'
# This ensures we are looking in the local framework directory
require File.join(Msf::Config.install_root, 'lib', 'msf', 'core', 'build_vuln')

class MetasploitModule < Msf::Auxiliary
  include Msf::Auxiliary::Report

  def initialize(info = {})
    super(update_info(info,
      'Name'           => 'Vulnerable Vim Lab Builder',
      'Description'    => %q{
        This module automates the creation and teardown of a vulnerable Vim environment.
        It builds a Docker container and ensures clean removal after testing.
      },
      'Author'         => [ 'Ganesh' ],
      'License'        => MSF_LICENSE,
      'References'     => [ [ 'URL', 'https://github.com/vim/vim/issues/4173' ] ]
    ))

    register_options([
      OptString.new('DOCKERFILE_PATH', [true, 'Path to Dockerfile', 'tools/dev/vulnerable_targets/vim_rce/']),
      OptString.new('IMAGE_NAME', [true, 'Name for the Docker image', 'msf-vim-target'])
    ])
  end

  def run
    print_status("Initializing BuildVuln engine...")
    @builder = Msf::BuildVuln.new(datastore['IMAGE_NAME'])

    begin
      print_status("Building Docker image: #{datastore['IMAGE_NAME']}...")
      unless @builder.build(datastore['DOCKERFILE_PATH'])
        print_error("Failed to build Docker image.")
        return
      end

      print_status("Starting the vulnerable container...")
      container_id = @builder.start

      if container_id
        print_good("Container started! ID: #{container_id[0...12]}")
        print_status("-------------------------------------------------------")
        print_status("LAB IS LIVE. Press Ctrl+C to shut down and cleanup.")
        print_status("-------------------------------------------------------")
        
        # Keep the module alive so the user can test their exploit
        while true
          sleep 2
        end
      else
        print_error("Failed to start container.")
      end

    rescue Interrupt
      print_warning("Interrupted by user. Initiating teardown...")
    ensure
      # This block runs NO MATTER WHAT (error, success, or Ctrl+C)
      if @builder && @builder.container_id
        print_status("Cleaning up Docker resources...")
        if @builder.cleanup
          print_good("Lab environment destroyed successfully.")
        else
          print_error("Cleanup failed. Manual removal may be required.")
        end
      end
    end
  end
end
