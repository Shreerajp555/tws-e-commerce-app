module "eks" {

  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.1"

  cluster_name                   = local.name
  cluster_endpoint_public_access = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.public_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets


  eks_managed_node_groups = {

    tws-demo-ng = {
      min_size     = 1
      max_size     = 1
      desired_size = 1

      instance_types = ["m7i-flex.large"]
      capacity_type  = "ON_DEMAND"

      disk_size = 30

      tags = {
        Name = "tws-demo-ng"
        Environment = "dev"
      }
    }
  }

  tags = local.tags


}

data "aws_instances" "eks_nodes" {
  instance_tags = {
    "eks:cluster-name" = module.eks.cluster_name
  }

  filter {
    name   = "instance-state-name"
    values = ["running"]
  }

  depends_on = [module.eks]
}
