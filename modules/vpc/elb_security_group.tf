resource "aws_security_group" "frontend_lb_sg" {
  vpc_id = aws_vpc.my_vpc.id
  
  ingress {
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "Allow inboud traffic on port 80 for the world"
    to_port = 80
    from_port = 80
    protocol = "tcp"
  }

  egress {
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "Allow outbound traffic on port 80 for the world"
    to_port = 80
    from_port = 80
    protocol = "tcp"
  }
}