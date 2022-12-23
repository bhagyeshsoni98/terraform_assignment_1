resource "aws_security_group" "frontend_sg" {
  name        = "frontend_sg"
  description = "SG for frontend instances"
  vpc_id      = var.vpc_id

  tags = {
    Name = "frontend-instance-sg"
  }
}

resource "aws_security_group" "backend_sg" {
  name        = "backend_sg"
  description = "Security Group for db instances"
  vpc_id      = var.vpc_id

  tags = {
    Name = "backend-instance-sg"
  }
}

resource "aws_security_group_rule" "frontend_ingress_ssh" {
  type              = "ingress"
  description       = "SSH for frontend"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.frontend_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "frontend_ingress_https" {
  type              = "ingress"
  description       = "HTTPS for frontend"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.frontend_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "frontend_ingress_http" {
  type              = "ingress"
  description       = "HTTP for frontend"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.frontend_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "frontend_ingress_db" {
  type                     = "ingress"
  description              = "Allow DB instance traffic for frontend"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.frontend_sg.id
  source_security_group_id = aws_security_group.backend_sg.id
}

resource "aws_security_group_rule" "frontend_sg_allow_all_outbound_traffic" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.frontend_sg.id
}

resource "aws_security_group_rule" "db_ingress_frontend" {
  type                     = "ingress"
  description              = "Allow frontend instance traffic for DB instance"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.backend_sg.id
  source_security_group_id = aws_security_group.frontend_sg.id
}

resource "aws_security_group_rule" "backend_sg_allow_all_outbound_traffic" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.backend_sg.id
}

resource "aws_security_group_rule" "frontend_sg_custom_rule" {
  count             = length(var.frontend_sg_rules)
  type              = var.frontend_sg_rules[count.index].type
  from_port         = var.frontend_sg_rules[count.index].from_port
  to_port           = var.frontend_sg_rules[count.index].to_port
  protocol          = var.frontend_sg_rules[count.index].protocol
  cidr_blocks       = var.frontend_sg_rules[count.index].cidr_blocks
  security_group_id = aws_security_group.frontend_sg.id
}

resource "aws_security_group_rule" "backend_sg_rules" {
  count             = length(var.backend_sg_rules)
  type              = var.backend_sg_rules[count.index].type
  from_port         = var.backend_sg_rules[count.index].from_port
  to_port           = var.backend_sg_rules[count.index].to_port
  protocol          = var.backend_sg_rules[count.index].protocol
  cidr_blocks       = var.backend_sg_rules[count.index].cidr_blocks
  security_group_id = aws_security_group.frontend_sg.id
}