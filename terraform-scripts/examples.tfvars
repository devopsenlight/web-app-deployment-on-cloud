cluster_name = "webapp-dev"

# AWS CLI config profile
aws_profile = "default"
aws_region  = "ap-south-1"

ec2_key_name = ""
ec2_key      = ""

vpc_cidr                 = "10.4.20.0/24"
vpc_az1                  = "ap-south-1a"
vpc_az2                  = "ap-south-1b"
vpc_public_subnet1_cidr  = "10.4.20.0/26"
vpc_public_subnet2_cidr  = "10.4.20.64/26"
vpc_private_subnet1_cidr = "10.4.20.128/26"
vpc_private_subnet2_cidr = "10.4.20.192/26"

k8s_desired_size        = 2
k8s_max_size            = 3
k8s_min_size            = 1
k8s_node_instance_types = ["t3.medium"]
