# -*- coding: binary -*-
require 'open3'

module Msf
  ###
  # This class provides an interface for building and managing 
  # vulnerable environments (containers) for exploit testing.
  ###
  class BuildVuln

    attr_reader :container_id

    # @param [String] image The Docker/Podman image name to use
    def initialize(image)
      @image = image
      @container_id = nil
    end

    # Builds a custom image from a Dockerfile
    # @param [String] path The directory containing the Dockerfile
    # @param [String] tag The name to give the new image
    # @return [Boolean] true if build was successful
    def build(path, tag)
      puts "[*] Building custom vulnerable target: #{tag}..."
      # This executes the actual docker build command
      success = system("docker build -t #{tag} #{path}")

      # Update the internal image name to the new tag if successful
      @image = tag if success
      success
    end

    # Starts the container environment with optional port mapping.
    # Uses -it to ensure the container stays alive for the duration of the test.
    # @param [String] port_map Format "host_port:container_port"
    # @return [String, nil] The Container ID if successful
    def start(port_map: nil)
      # -d: Detached, -i: Interactive, -t: TTY
      cmd = "docker run -d -it "
      cmd << "-p #{port_map} " if port_map
      cmd << @image

      stdout, stderr, status = Open3.capture3(cmd)
      
      if status.success?
        @container_id = stdout.strip
        return @container_id
      else
        return nil
      end
    end

    # Stops and removes the container
    def cleanup
      return false unless @container_id
      system("docker rm -f #{@container_id} > /dev/null 2>&1")
      @container_id = nil
      true
    end

  end
end
