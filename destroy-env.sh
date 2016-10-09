#!/bin/bash

# collect all the instance ids
echo "Running destroy script on your AWS account............"

echo ""
echo "Collecting all the 4 instances in running status........"
instances=$(aws ec2 describe-instances --query 'Reservations[*].Instances[*].[Placement.AvailabilityZone, State.Name, InstanceId]' --output text | grep us-west-2b | grep 'running' | awk '{print $3}')

# detach all the instances from the auto scaling group
echo ""
echo "Detatching all the 4 instances from WEBSERVERDEMO auto-scaling-group"
aws autoscaling detach-instances --instance-ids $instances --auto-scaling-group-name webserverdemo --should-decrement-desired-capacity

# aws autoscaling delete autoscaling configuration
echo ""
echo "Deleting auto-scaling-group WEBSERVERDEMO............"
aws autoscaling delete-auto-scaling-group --auto-scaling-group-name webserverdemo --force-delete
echo ""
echo "WEBSERVERDEMO deleted successfully!"

# aws autoscaling delete-launch configuration
echo ""
echo "Deleting launch configuration WEBSERVER..............."
aws autoscaling delete-launch-configuration --launch-configuration-name webserver
echo ""
echo "WEBSERVER deleted successfully!"

#deregister instances
echo ""
echo "Deregistering the instances from the load-balancer MY-LOAD-BALANCER......"
aws elb deregister-instances-from-load-balancer --load-balancer-name my-load-balancer --instances $instances
echo ""
echo "Deregistered instances successfully!"

# aws elb delete listeners 
echo ""
echo "Deleting the listener created for MY-LOAD-BALANCER......"
aws elb delete-load-balancer-listeners --load-balancer-name my-load-balancer --load-balancer-ports 80
echo ""
echo "Listener deleted successfully!"

# aws elb delete load-balancers
echo ""
echo "Deleing the load-balancer MY-LOAD-BALANCER............."
aws elb delete-load-balancer --load-balancer-name my-load-balancer
echo ""
echo "MY-LOAD-BALANCER deleted successfully!"

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

