resource "aws_eip" "EIP-NAT-GW1" {
  tags = {
    Name = "NAT-GW-EIP1"
  }
}

resource "aws_eip" "EIP-NAT-GW2" {
  tags = {
    Name = "NAT-GW-EIP2"
  }
}

resource "aws_nat_gateway" "nat_gw1" {
  allocation_id = aws_eip.EIP-NAT-GW1.id
  subnet_id     = var.PUB_SUB1_ID

  tags = {
    Name = "nat_gw1"
  }
  depends_on = [var.IGW_ID]
}

resource "aws_nat_gateway" "nat_gw2" {
  allocation_id = aws_eip.EIP-NAT-GW2.id
  subnet_id     = var.PUB_SUB2_ID

  tags = {
    Name = "nat_gw2"
  }
  depends_on = [var.IGW_ID]
}
resource "aws_route_table" "pri-rt-a" {
  vpc_id = var.VPC_ID
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw1.id
  }
  tags = {
    Name = "pri-rt-a"
  }
}
resource "aws_route_table_association" "pri-sub3-with-pri-rt-a" {
  subnet_id      = var.PRI_SUB3_ID
  route_table_id = aws_route_table.pri-rt-a.id
}
resource "aws_route_table" "pri-rt-b" {
  vpc_id = var.VPC_ID

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw2.id
  }

  tags = {
    Name = "pri-rt-b"
  }
}
resource "aws_route_table_association" "pri-sub4-with-pri-rt-b" {
  subnet_id      = var.PRI_SUB4_ID
  route_table_id = aws_route_table.pri-rt-b.id
}