output "sg_eks_id" {
  value = aws_security_group.eks_nodes.id
}

output "sg_rds_id" {
  value = aws_security_group.rds.id
}

output "sg_fsx_id" {
  value = aws_security_group.fsx.id
}
