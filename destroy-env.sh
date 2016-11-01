#!/bin/bash

# collect all the instance ids
echo "Running destroy script on your AWS account............"

echo ""
echo "Collecting all the 4 instances in running status........"
instances=$(aws ec2 describe-instances --query 'Reservations[*].Instances[*].[Placement.AvailabilityZone, State.Name, InstanceId]' --output text | grep us-west-2b | grep 'running' | awk '{print $3}')

autoscalinggroup=$(aws autoscaling describe-auto-scaling-instances --query 'AutoScalingInstances[0].AutoScalingGroupName')

# detach all the instances from the auto scaling group
echo ""
echo "Detatching all the 4 instances from auto-scaling-group"
aws autoscaling detach-instances --instance-ids $instances --auto-scaling-group-name $autoscalinggroup --should-decrement-desired-capacity

# aws autoscaling delete autoscaling configuration
echo ""
echo "Deleting auto-scaling-group............"
aws autoscaling delete-auto-scaling-group --auto-scaling-group-name $autoscalinggroup --force-delete
echo ""
echo "Auto-scaling group deleted successfully!"

launchconfig=$(aws autoscaling describe-launch-configurations --query 'LaunchConfigurations[*].LaunchConfigurationName')

# aws autoscaling delete-launch configuration
echo ""
echo "Deleting launch configuration..............."
aws autoscaling delete-launch-configuration --launch-configuration-name $launchconfig
echo ""
echo "Launch Configuration deleted successfully!"

loadbalancer=$(aws elb describe-load-balancers --query 'LoadBalancerDescriptions[*].LoadBalancerName')

#deregister instances
echo ""
echo "Deregistering the instances from the load-balancer MY-LOAD-BALANCER......"
aws elb deregister-instances-from-load-balancer --load-balancer-name $loadbalancer --instances $instances
echo ""
echo "Deregistered instances successfully!"

# aws elb delete listeners 
echo ""
echo "Deleting the listener created for MY-LOAD-BALANCER......"
aws elb delete-load-balancer-listeners --load-balancer-name $loadbalancer --load-balancer-ports 80
echo ""
echo "Listener deleted successfully!"

# aws elb delete load-balancers
echo ""
echo "Deleing the load-balancer MY-LOAD-BALANCER............."
aws elb delete-load-balancer --load-balancer-name $loadbalancer
echo ""
echo "LOAD-BALANCER deleted successfully!"

# delete all the instances
echo ""
echo "Deleting all the instances running......."
aws ec2 terminate-instances --instance-ids $instances
echo ""
echo "Instances deletion successful!"

echo ""
echo "Destroy  script run is successful."
echo ""
echo  "----------------------------------------------------------------------------------------------------------------"

