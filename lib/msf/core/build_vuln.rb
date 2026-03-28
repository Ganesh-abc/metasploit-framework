# -*- coding: binary -*-
require 'open3'

module Msf
  ###
  # This class provides an interface for building and managing 
  # vulnerable environments (containers) for exploit testing.
  # @author Ganesh
  ###
  class BuildVuln
    attr_reader :container_id, :image_name

    def initialize(image_name)
      @image_name = image_name
      @container_id = nil
    end

    # Builds the Docker image
    def build(dockerfile_path)
      stdout, stderr, status = Open3.capture3("docker build -t #{@image_name} #{dockerfile_path}")
      return status.success?
    end

    # Starts the container and stores the ID
    def start
      stdout, stderr, status = Open3.capture3("docker run -d #{@image_name} tail -f /dev/null")
      if status.success?
        @container_id = stdout.strip
        return @container_id
      end
      nil
    end

    # The "GSoC Winner" Cleanup Function
    # Forces removal of the container to prevent resource leaks
    def cleanup
      return false unless @container_id
      
      # -f flag handles stopping and removing in one go
      _, _, status = Open3.capture3("docker rm -f #{@container_id}")
      
      if status.success?
        @container_id = nil
        return true
      end
      false
    end
  end
end
