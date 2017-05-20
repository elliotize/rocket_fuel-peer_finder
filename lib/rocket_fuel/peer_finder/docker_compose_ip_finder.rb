require 'docker-api'

module RocketFuel
  module PeerFinder
    class DockerComposeIPFinder
      NETWORK = 'dockercompose_default'
      def ips_of_peers
        ips = []
        Docker::Container.all.each do |container|
          next if container.id.match(/#{ENV['HOSTNAME']}/)
          ips << container.info['NetworkSettings']['Networks'][NETWORK]['IPAddress']
        end
        ips
      end
    end
  end
end
