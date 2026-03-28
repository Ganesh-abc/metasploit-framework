# -*- coding: binary -*-

class MetasploitModule < Msf::Auxiliary
  # This allows the module to use Metasploit's built-in status reporting
  include Msf::Auxiliary::Report

  def initialize(info = {})
    super(
      update_info(
        info,
        'Name'           => 'Vulnerable Vim Lab Builder',
        'Description'    => %q{
          This module automates the creation of a vulnerable Vim environment.
          It builds a Debian-based Docker container, injects a modeline exploit,
          and verifies that the environment is ready for RCE testing.
        },
        'Author'         => [ 'Ganesh' ], # Your name here for the credits!
        'License'        => MSF_LICENSE,
        'References'     => [ [ 'URL', 'https://github.com/vim/vim/issues/4173' ] ],
        'Notes'          => {
          'Stability'    => [ CRASH_SAFE ],
          'SideEffects'  => [ ARTIFACTS_ON_DISK ]
        }
      )
    )

    # We can add options here later (like custom ports or images)
    register_options([
      OptString.new('IMAGE_NAME', [true, 'The name for the built Docker image', 'msf-vim-target']),
      OptString.new('DOCKERFILE_PATH', [true, 'Path to the Dockerfile', 'tools/dev/vulnerable_targets/vim_rce/'])
    ])
  end

  def run
    print_status("Initializing BuildVuln engine...")
    builder = Msf::BuildVuln.new(datastore['IMAGE_NAME'])

    # 1. Build the target
    print_status("Building Docker image from #{datastore['DOCKERFILE_PATH']}...")
    if builder.build(datastore['DOCKERFILE_PATH'], datastore['IMAGE_NAME'])
      print_good("Image #{datastore['IMAGE_NAME']} built successfully.")
    else
      print_error("Failed to build Docker image.")
      return
    end

    # 2. Start the container
    print_status("Starting the vulnerable container...")
    container_id = builder.start
    if container_id
      print_good("Container started! ID: #{container_id[0...12]}")
    else
      print_error("Failed to start container.")
      return
    end

    # 3. Final instruction to user
    print_line("")
    print_status("Vulnerable environment is now LIVE.")
    print_status("You can now test exploits against container: #{container_id[0...12]}")
    print_warning("Don't forget to run 'docker rm -f #{container_id[0...12]}' when finished, or use the cleanup method.")
  end
end
