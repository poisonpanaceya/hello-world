variable "az-subnet-mapping" {
  type        = "list"
  description = "Lists the subnets to be created in their respective AZ."
  default = [
    {
      name = "Hello Subnet B"
      az   = "eu-central-1b"
      cidr = "10.0.0.0/24"
    },
    {
      name = "Hello Subnet A"
      az   = "eu-central-1a"
      cidr = "10.0.1.0/24"
    },
  ]
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Hello Vpc"
  }
}

resource "aws_subnet" "main" {
  count = "${length(var.az-subnet-mapping)}"

  cidr_block              = "${lookup(var.az-subnet-mapping[count.index], "cidr")}"
  vpc_id                  = "${aws_vpc.main.id}"
  availability_zone       = "${lookup(var.az-subnet-mapping[count.index], "az")}"

  tags = {
    Name = "${lookup(var.az-subnet-mapping[count.index], "name")}"
  }
}
resource "aws_route_table" "main" {
    vpc_id = "${aws_vpc.main.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.main.id}"
    }

    tags {
        Name = "Hello Route Table"
    }
}


resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name = "Hello GW"
  }
}

resource "aws_lb_target_group" "main" {
  name     = "Hello-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.main.id}"
}
