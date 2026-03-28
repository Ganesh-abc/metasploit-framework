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

    # Starts the container environment
    # @return [String, nil] The Container ID if successful, nil otherwise
    def start
      # Start the container in detached mode and get the ID
      stdout, stderr, status = Open3.capture3("docker run -d #{@image}")
      
      if status.success?
        @container_id = stdout.strip
        return @container_id
      else
        # Log the error (In MSF core, we usually raise an error or return nil)
        return nil
      end
    end

    # Stops and removes the container
    # @return [Boolean] true if cleaned up successfully
    def cleanup
      return false unless @container_id
      
      # Force remove the container to ensure it's gone
      system("docker rm -f #{@container_id} > /dev/null 2>&1")
      @container_id = nil
      true
    end

  end
end
