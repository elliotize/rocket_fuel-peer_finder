require 'aws-sdk'
require 'ec2_metadata'

module RocketFuel
  module PeerFinder
    class AutoScalingGroupIPFinder
      def ips_of_peers
        ips = []
        asg.instances.each do |instance|
          next if instance.id == instance_id
          ips << Aws::EC2::Instance.new(instance.id, client: ec2_client).private_ip_address
        end
        ips
      end

      private

      def asg_client
        @asg_client ||= Aws::AutoScaling::Client.new(region: region)
      end

      def ec2_client
        @ec2_client ||= Aws::EC2::Client.new(region: region)
      end

      def asg
        Aws::AutoScaling::AutoScalingGroup.new(asg_name, client: asg_client)
      end

      def asg_name
        asis = asg_client.describe_auto_scaling_instances(instance_ids: [instance_id])
        asis.auto_scaling_instances.first.auto_scaling_group_name
      end

      def region
        Ec2Metadata[:placement][:'availability-zone'].scan(/[\S]+\-[\d]/).first
      end

      def instance_id
        Ec2Metadata[:instance_id]
      end
    end
  end
end
