# variable "instancias" {
#   description = "Nombre de las instancias"
#   type = list(string)
#   default = [ "apache" ]
# }


resource "aws_instance" "public_instance" {
# for_each = toset(var.instancias)
  ami           = var.ec2_specs.ami
  instance_type = var.ec2_specs.instance_type
  subnet_id     = aws_subnet.public_subnet.id
  key_name      = data.aws_key_pair.key.key_name
  vpc_security_group_ids = [aws_security_group.sg_public_instance.id]
  # user_data = file("scripts/user_data.sh")  #Llama al archivo user_data.sh para que se ejecute al iniciar la instancia
  tags = {
    "Name"= "public-${local.sufix}"
    }
}

resource "aws_instance" "private_instance" {
  ami           = var.ec2_specs.ami
  instance_type = var.ec2_specs.instance_type
  subnet_id     = aws_subnet.public_subnet.id
  key_name      = data.aws_key_pair.key.key_name
  vpc_security_group_ids = [aws_security_group.sg_public_instance.id]
  tags = {
    "Name"= "private-${local.sufix}"
    }
}

