## create an IAM role and instance profile for EC2 instances to use SSM
data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
  

}

data "aws_iam_policy" "ec2_policy" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  tags = merge (
    local.default_tags,
    {
      Name = "AmazonSSMManagedInstanceCore"
    }
  )
}


resource "aws_iam_role" "ec2_role" {
  name               = "ec2_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags = merge( 
    local.default_tags,
    {
      Name = "ec2_role"
    }
  )
}


##attach the policy to the role
resource "aws_iam_policy_attachment" "attach-policy" {
  name       = "attach-policy"
  roles      = [aws_iam_role.ec2_role.name]
  policy_arn = data.aws_iam_policy.ec2_policy.arn
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_instance_profile"
  role = aws_iam_role.ec2_role.name
}