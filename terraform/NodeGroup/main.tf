resource "aws_eks_node_group" "node_group" {
  cluster_name = var.EKS_CLUSTER_NAME
  node_group_name = "${var.EKS_CLUSTER_NAME}-node_group"
  node_role_arn = var.NODE_GROUP_ARN
  subnet_ids = [
    var.PRI_SUB3_ID,
    var.PRI_SUB4_ID
  ]

  scaling_config {
    desired_size = 2
    max_size = 2
    min_size = 2
  }

  ami_type = "AL2_x86_64"
  capacity_type = "ON_DEMAND"
  disk_size = 20
  force_update_version = false
  instance_types = ["t3.small"]
  labels = {
    role = "${var.EKS_CLUSTER_NAME}-Node-group-role",
    name = "${var.EKS_CLUSTER_NAME}-node_group"
  }
  version = "1.27"
}
