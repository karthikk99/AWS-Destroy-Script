#!/bin/bash

# collect all the instance ids
instances=$(aws ec2 describe-instances --query 'Reservations[*].Instances[*].[Placement.AvailabilityZone, State.Name, InstanceId]' --output text | grep us-west-2b | grep 'running' | awk '{print $3}')

# detach all the instances from the auto scaling group
aws autoscaling detach-instances --instance-ids $instances --auto-scaling-group-name webserverdemo --should-decrement-desired-capacity

# aws autoscaling delete autoscaling configuration
aws autoscaling delete-auto-scaling-group --auto-scaling-group-name webserverdemo --force-delete

# aws autoscaling delete-launch configuration
aws autoscaling delete-launch-configuration --launch-configuration-name webserver

#deregister instances
aws elb deregister-instances-from-load-balancer --load-balancer-name my-load-balancer --instances $instances

# aws elb delete listeners 
aws elb delete-load-balancer-listeners --load-balancer-name my-load-balancer --load-balancer-ports 80

# aws elb delete load-balancers
aws elb delete-load-balancer --load-balancer-name my-load-balancer

# delete all the instances
aws ec2 terminate-instances --instance-ids $instances
