
#
# Control Plane Resources
#

resource "aws_iam_role" "k8s" {
  name = "k8s-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "k8s_policy_attachment1" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.k8s.name
}

resource "aws_eks_cluster" "k8s" {
  name     = var.cluster_name
  role_arn = aws_iam_role.k8s.arn

  vpc_config {
    subnet_ids = [
      aws_subnet.private_subnet1.id,
      aws_subnet.private_subnet2.id
    ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.k8s_policy_attachment1,
  ]
}


#
# Worker Node Resources
#

resource "aws_iam_role" "k8s_node_group" {
  name = "noderole"

  assume_role_policy = jsonencode({
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.k8s_node_group.name
}

resource "aws_iam_role_policy_attachment" "cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.k8s_node_group.name
}

resource "aws_iam_role_policy_attachment" "ecr_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.k8s_node_group.name
}

resource "aws_security_group" "workers" {
  vpc_id = aws_vpc.main.id

  # Based on https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html

  ingress {
    description = "Inbound traffic from other workers"
    from_port   = 0
    to_port     = 0
    protocol    = "all"
    self        = true
  }

  ingress {
    description = "Inbound HTTPS traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "All other inbound traffic"
    from_port   = 1025
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "all"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_launch_template" "k8s" {
  name     = var.cluster_name
  key_name = var.ec2_key_name

  vpc_security_group_ids = [
    aws_eks_cluster.k8s.vpc_config[0].cluster_security_group_id,
    aws_security_group.workers.id
  ]

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.cluster_name}"
    }
  }
}

resource "aws_eks_node_group" "k8s" {
  cluster_name    = aws_eks_cluster.k8s.name
  node_group_name = var.cluster_name
  node_role_arn   = aws_iam_role.k8s_node_group.arn
  instance_types  = var.k8s_node_instance_types
  subnet_ids = [
    aws_subnet.private_subnet1.id,
    aws_subnet.private_subnet2.id
  ]

  launch_template {
    id      = aws_launch_template.k8s.id
    version = aws_launch_template.k8s.latest_version
  }

  scaling_config {
    desired_size = var.k8s_desired_size
    min_size     = var.k8s_min_size
    max_size     = var.k8s_max_size
  }

  # Allow external changes without causing plan diffs
  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  depends_on = [
    aws_iam_role_policy_attachment.worker_node_policy,
    aws_iam_role_policy_attachment.cni_policy,
    aws_iam_role_policy_attachment.ecr_read_only,
    aws_eks_cluster.k8s,
  ]
}

provider "null" {}

resource "null_resource" "update_kubeconfig" {
  provisioner "local-exec" {
    command = "aws eks --region=${var.aws_region} update-kubeconfig --name ${var.cluster_name} --alias iams"
  }

  depends_on = [aws_eks_node_group.k8s]
}

resource "null_resource" "install_helm_release1" {
  provisioner "local-exec" {
    command = "sudo -u root /root/bin/helm install my-release-fe s3://frontendchartrakshit/frontend-foldername/frontend-0.1.0.tgz"
  }

  depends_on = [null_resource.update_kubeconfig]
}

resource "null_resource" "install_helm_release2" {
  provisioner "local-exec" {
    command = "sudo -u root /root/bin/helm install my-release-be s3://backendchartrakshit/backend-foldername/backend-0.1.0.tgz"
  }

  depends_on = [null_resource.update_kubeconfig]
}

resource "null_resource" "uninstall_fe_release" {
  provisioner "local-exec" {
    # Uninstall Helm chart during resource destruction
    when    = destroy
    command = "sudo -u root /root/bin/helm uninstall my-release-fe"
  }
}

resource "null_resource" "uninstall_be_release" {
  provisioner "local-exec" {
    # Uninstall Helm chart during resource destruction
    when    = destroy
    command = "sudo -u root /root/bin/helm uninstall my-release-be"
  }
}
