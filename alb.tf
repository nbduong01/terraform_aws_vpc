
resource "aws_lb_target_group" "my-tg-ec2" {
  health_check {
    interval            = 10
    path                = "/var/www/html"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  name        = "my-test-tg-ec2"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.vpc.id  
}

resource "aws_lb_target_group_attachment" "my-alb-target-group-attachment1" {
  target_group_arn = aws_lb_target_group.my-tg-ec2.arn
  target_id        = aws_instance.Wp_server01.id
  port             = 80
}
resource "aws_lb_target_group_attachment" "my-alb-target-group-attachment2" {
  target_group_arn = aws_lb_target_group.my-tg-ec2.arn
  target_id        = aws_instance.Wp_server02.id
  port             = 80
}

resource "aws_lb_target_group" "my-tg-jenkins" {
  health_check {
    interval            = 10
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  name        = "my-test-tg-jenkins"
  port        = 8080
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.vpc.id  
}
resource "aws_lb_target_group_attachment" "my-alb-target-group-attachment3" {
  target_group_arn = aws_lb_target_group.my-tg-jenkins.arn
  target_id        = aws_instance.Jenkins.id
  port             = 8080
}

resource "aws_lb" "my-aws-alb" {
  name     = "my-test-alb"
  internal = false

  security_groups = [aws_security_group.my-alb-sg.id]

  subnets = [
    aws_subnet.public_subnet_az1.id,
    aws_subnet.public_subnet_az2.id,
  ]

  tags = {
    Name = "my-test-alb"
  }

  ip_address_type    = "ipv4"
  load_balancer_type = "application"
}

resource "aws_lb_listener" "my-test-alb-listner-ec2" {
  load_balancer_arn = aws_lb.my-aws-alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my-tg-ec2.arn
  }
}

resource "aws_lb_listener" "my-test-alb-listner-jenkins" {
  load_balancer_arn = aws_lb.my-aws-alb.arn
  port              = 8080
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my-tg-jenkins.arn
  }
}
resource "aws_security_group" "my-alb-sg" {
  name   = "my-alb-sg"
  vpc_id = aws_vpc.vpc.id
}

resource "aws_security_group_rule" "inbound_ssh" {
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.my-alb-sg.id
  to_port           = 22
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "inbound_http" {
  from_port         = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.my-alb-sg.id
  to_port           = 80
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "inbound_jenkins" {
  from_port         = 8080
  protocol          = "tcp"
  security_group_id = aws_security_group.my-alb-sg.id
  to_port           = 8080
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "outbound_all" {
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.my-alb-sg.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}
