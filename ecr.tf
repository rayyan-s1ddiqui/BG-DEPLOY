resource "aws_ecr_repository" "pharmacy_ecr" {
  name                 = "pharmacy-repo"
  image_tag_mutability = "MUTABLE"
  force_delete = true
  tags = { Name = "pharmacy-ecr" }
}
