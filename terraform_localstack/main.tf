# Konfiguriere den Provider. 'aws' wurde so als name in terraform.tf definiert.
provider "aws" {
  access_key                  = "test"
  secret_key                  = "test"
  region                      = "eu-central-1"
  s3_use_path_style           = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true  

  endpoints {
    s3 = "http://localhost:4566"
  }
}

# data block, um die neueste Ubuntu AMI-ID zu erhalten.
# D.h. wir suchen nach einem Amazon Machine Image (AMI) von Ubuntu, 
# das in der Region verfügbar ist, in der wir unsere Instanz erstellen möchten.
data "aws_ami" "ubuntu" { # aufrufbar mit 'data.aws_ami.ubuntu'
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  owners = ["099720109477"] # Canonical
}

# resource definiert eine Komponente, die von Terraform verwaltet wird. In diesem Fall erstellen wir eine AWS-EC2-Instanz.
# Hier eine Instanz name "app_server" vom Typ "aws_instance" (EC2-Instanz).
resource "aws_instance" "app_server" { # aufrufbar mit 'aws_instance.app_server'
  ami           = data.aws_ami.ubuntu.id # oben definierte AMI-ID wird hier verwendet, um die Instanz mit dem neuesten Ubuntu-Image zu erstellen.
  instance_type = "t2.micro" # definiert den Instanztyp, der die Hardware-Ressourcen der EC2-Instanz bestimmt. 't2.micro' ist eine kostengünstige Option, die für kleine Anwendungen oder Testzwecke geeignet ist.

  tags = {
    Name = "learn-terraform" # Setzen des Instanznames als Tag 'learn-terraform' für eine bessere Identifikation in der AWS-Konsole.
  }
}
