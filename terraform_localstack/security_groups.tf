# Eine Security Group ist im Grunde eine AWS Netzwerk-Firewall
# Sie legt fest:
# - Welche Verbindungen hereinkommen dürfen (Ingress)
# - Welche Verbindungen hinausgehen dürfen (Egress)

# aws_security_group definiert die Firewall an sich selbst
# aws_security_group_rule erstellt eine bestimmte Regel für die Gruppe

# WICHTIG: da in diesem Beispiel kein EC2 konfiguriert ist, wird die security_group auskommentiert
# Die Infra besteht aus S3 und Postgres, die App greift nur darauf zu

# resource "aws_security_group" "app" {
#   name = "${local.service_name}-app-sg"
#
#   # eingehend nur 8080 erlaubt
#   ingress {
#     from_port   = 8080
#     to_port     = 8080
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }