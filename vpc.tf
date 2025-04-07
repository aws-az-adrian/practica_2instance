resource "aws_vpc" "vpc_virginia" {
  cidr_block = var.virgina_cidr
  # cidr_block = lookup(var.virgina_cidr,terraform.workspace) #Va a mirar en que workspace estamos y va a buscar el cidr correspondiente
  tags = {
    Name = "VPC-Virginia-${local.sufix}"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc_virginia.id
  cidr_block              = var.subnets[0] #Llamando a la primera subred
  map_public_ip_on_launch = true
  tags = {
    Name = "Public_Subnet-${local.sufix}"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.vpc_virginia.id
  cidr_block = var.subnets[1] #Llamando a la segunda subred 
  tags = {
    Name = "Private_Subnet-${local.sufix}"
  }
  depends_on = [
    aws_subnet.public_subnet # Asegurando que la subred pública se cree primero
  ]
}
#Creamos el gateway de internet, que es el que permite la salida a internet de la subred publica.
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_virginia.id

  tags = {
    Name = "igw vpc virginia-${local.sufix}"
  }
}
# Creamos la tabla de rutas publica.
resource "aws_route_table" "public_ctr" {
  vpc_id = aws_vpc.vpc_virginia.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }


  tags = {
    Name = "public_crt-${local.sufix}"
  }
}



#### Esto lo que hace es asociar una subred a una tabla de rutas, en este caso la subred publica a la tabla de rutas publica
resource "aws_route_table_association" "crta_public_subnet" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_ctr.id
}

resource "aws_security_group" "sg_public_instance" {
  name        = "Public Instance Security Group"
  description = "Permitir trafico ICMP para habilitar ping"
  vpc_id      = aws_vpc.vpc_virginia.id


ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"] # Permite ping desde cualquier IP (modifica según sea necesario)
  }

ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Permite ping desde cualquier IP (modifica según sea necesario)
  }


egress {
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}
 
 
tags = {
    Name = "allow-ping-and.ssh"
  }

}

