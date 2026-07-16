resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr
    enable_dns_support = true
    enable_dns_hostnames = true
    tags = merge(var.tags, {Name = "${var.name_prefix}-vpc"})
}

resource "aws_flow_log" "vpc" {
    vpc_id = aws_vpc.main.id
    traffic_type = "ALL"
    log_destination_type = "cloud-watch-logs"
    log_destination = var.flow_logs_destination_arn
    iam_role_arn = var.vpc_flow_logs_iam_arn
}

resource "aws_subnet" "public"{
    count = length(var.azs)
    cidr_block = var.public_subnet_cidrs[count.index]
    vpc_id = aws_vpc.main.id
    availability_zone = var.azs[count.index]
    map_public_ip_on_launch =  true
    tags = merge(var.tags, {Name = "${var.azs[count.index]}-${var.name_prefix}-public-subnet"})
}

resource "aws_subnet" "private"{
    count = length(var.azs)
    cidr_block = var.private_subnet_cidrs[count.index]
    vpc_id = aws_vpc.main.id
    availability_zone = var.azs[count.index]
    tags = merge(var.tags, {Name = "${var.azs[count.index]}-${var.name_prefix}-private-subnet"})
}


resource "aws_subnet" "database"{
    count = length(var.azs)
    cidr_block = var.database_subnet_cidrs[count.index]
    vpc_id = aws_vpc.main.id
    availability_zone = var.azs[count.index]
    tags = merge(var.tags, {Name = "${var.azs[count.index]}-${var.name_prefix}-private-database"})
}

resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id
    tags   = merge(var.tags, { Name = "${var.name_prefix}-igw" })
}

resource "aws_eip" "main"{
    count = var.nat_gateway_count
    domain = "vpc"
    tags   = merge(var.tags, { Name = "${count.index}-${var.name_prefix}-nat-eip" })
}

resource "aws_nat_gateway" "main" {
    count = var.nat_gateway_count
    allocation_id  = aws_eip.main[count.index].id
    subnet_id = aws_subnet.public[count.index].id
    depends_on = [aws_internet_gateway.main]
    tags   = merge(var.tags, { Name = "${count.index}-${var.name_prefix}-nat-gateway" })
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id
    tags   = merge(var.tags, { Name = "${var.name_prefix}-rt-public" })
}

resource "aws_route" "public_internet" {
    route_table_id         = aws_route_table.public.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public" {
    count          = length(var.azs)
    subnet_id      = aws_subnet.public[count.index].id
    route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
    count = length(var.azs)
    vpc_id = aws_vpc.main.id
    tags   = merge(var.tags, { Name = "${var.name_prefix}-rt-private-${var.azs[count.index]}" })
}

resource "aws_route" "private_internet" {
    count = length(var.azs)
    route_table_id         = aws_route_table.private[count.index].id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[min(count.index, var.nat_gateway_count - 1)].id
}

resource "aws_route_table_association" "private" {
    count          = length(var.azs)
    subnet_id      = aws_subnet.private[count.index].id
    route_table_id = aws_route_table.private[count.index].id
}


resource "aws_route_table_association" "database" {
    count          = length(var.azs)
    subnet_id      = aws_subnet.database[count.index].id
    route_table_id = aws_route_table.private[count.index].id
}

resource "aws_db_subnet_group" "main" {
    name       = "${var.name_prefix}-db-subnet-group"
    subnet_ids      = aws_subnet.database[*].id
    tags       = merge(var.tags, { Name = "${var.name_prefix}-db-subnet-group" })
}

resource "aws_elasticache_subnet_group" "main" {
    name       = "${var.name_prefix}-private-subnet-group"
    subnet_ids      = aws_subnet.private[*].id
    tags       = merge(var.tags, { Name = "${var.name_prefix}-private-subnet-group" })
}