module "eks"{
    source = "terraform-aws-modules/eks/aws"
    version = "19.21.0"
    cluster_name = demo-cluster
    cluster_version = "1.28"
    subnets = module.vpc.private_subnets
tags = {
        Name = "Demo-EKS-Cluster"
    }

vpc_id = module.vpc.vpc_id

workers_group = [
        {
            name = "Worker-Group-1"
            instance_type = "t2.micro"
            asg_desired_capacity = 1
        },
        {
            name = "Worker-Group-2"
            instance_type = "t2.micro"
            asg_desired_capacity = 1
        },
    ]
}
data "aws_eks_cluster" "cluster" {
    name = module.eks.cluster_id
}
data "aws_eks_cluster_auth" "cluster" {
    name = module.eks.cluster_id
}
