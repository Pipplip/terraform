# Terraform

https://developer.hashicorp.com/terraform/tutorials/aws-get-started/aws-manage

## Allgemein
- Infrastruktur wird deklarativ verwaltet als Code
- man definiert eine Infrastuktur und terraform setzt sie um
- HCL ist die Konfigurationssprache (HCL: HashiCorp Config Language)
- Alle .tf Dateien behandelt terraform als ein Modul (Konfiguration), unterschiedliche .tf Dateien gelten nur der menschlichen Strukturierung
- Terraform hält den aktuellen Zustand deiner Infrastruktur in einer Datei terraform.tfstate
(Damit weiß terraform was existiert und was geändert werden muss)

Terraform init liest nur .tf Dateien im Root Verzeichnis, nicht in Subdirectories

## Einzelne Schritte um eine Infrastruktur auszuführen
1. Scope: Infrastruktur identifizieren (was wird benötigt?)
2. Author: Schreibe die Konfiguration für die Infrastruktur
3. Initialize (init): Installiere alle benötigten Terraform provider
4. Plan (plan): Analysiere die Vorschau
5. Apply (apply): Führe Plan aus - In `main.tf` steht der Provider, also wohin die Infrastruktur deployed werden soll, z.B. AWS, Azure etc. In weiteren .tf Dateien steht dann was genau erstellt werden soll, z.B. S3 Bucket, EC2 Instanz etc.

Bei einem apply wird die Infrastruktur in die Cloud deployed. Wenn man mehrere Workspaces hat, haben die Services einfach unterschiedliche Namen, damit sie sich nicht gegenseitig beeinflussen.   
Sie befinden sich aber alle im gleichen Cloud-Space.   

Bsp:
```
AWS Account
│
├── my-bucket-dev
├── my-bucket-test
└── my-bucket-prod
```
Wichtig ist dabei, dass die Namen der Services richtig definiert sind:   
```
resource "aws_s3_bucket" "bucket" {
    bucket = "my-bucket-${terraform.workspace}"
}
```

## Schritt 1: terraform.tf in einem neuen Verzeichnis erstellen
Diese Datei konfiguriert terraform selbst.   
Also z.B. Version oder benötigte Provider (z.B. AWS)    

## Schritt 2: main.tf erstellen
Hier wird der Provider (z.B. AWS) selbst konfiguriert.   
main.tf und terraform.tf sind Voraussetzung und müssen immer erstellt werden.   

## Schritt 3: weitere configs erstellen
z.B. eine s3.tf für eine S3 Bucket Initialisierung    

## Schritt 4: terraform init (Vorbereitung)
Diesen Befehl in der Console ausführen, damit Terraform initialisiert wird. Es wird z.B. der Provider heruntergeladen (landen in .terraform/), Module und verbindet sich mit dem Backend um State Handling einzurichten.   
Tipp: `terraform fmt` und `terraform validate` formatiert und prüft die Syntax der .tf Dateien

## Schritt 5: terraform plan
Dieser Befehl prüft was schon bereits existiert und welche Änderungen nötig wären.   
z.B. `Plan: 2 to add, 1 to change, 0 to destroy.`

In CI/CD Pipelines macht man meist:   
`terraform plan -out=tfplan` speichert den Plan und diesen kann man später ausführen mit `terraform apply tfplan`

## Schritt 6: terraform apply
Stimmt der Plan und hat keine Fehler führt man die Konfiguration mit apply aus.   

## terraform.tfstate
Enthält den aktuellen Zustand + Metadaten.   
Diese Datei ist sehr wichtig und sollte nicht manuell geändert werden.   
Sie entsteht nachdem `terraform apply` ausgeführt wurde.   
Diese Datei enthält auch sensitive Daten wie Passwörter! Und sollte NICHT commited werden!     

## Workspaces
Workspaces sind eine Möglichkeit, mehrere getrennte Zustände (State Files) mit derselben Konfiguration zu verwalten.   
Dadurch kannst du z.B. verschiedene Umgebungen (dev, test, prod) oder verschiedene Deployments (z.B. in verschiedenen Regionen) mit derselben Terraform-Konfiguration verwalten, ohne dass sie sich gegenseitig beeinflussen.

Bsp.
- default
- test_euw1
- prod_euw1
- staging_euw1

Jeder Workspace hat seinen eigenen Terraform State, auch wenn der Code identisch ist.   

**Workspace anlegen und direkt wechseln:**      
`terraform workspace new test_euw1`

**Workspaces anzeigen:**   
`terraform workspace list`

**Workspace wechseln:**   
`terraform workspace select test_euw1`

Warum ist das nützlich?   
Du kannst damit z.B.:
- gleiche Infrastruktur mehrfach deployen
- getrennte Umgebungen simulieren (dev/test/prod)
- mit LocalStack mehrere isolierte Tests machen

Die Workspaces liegen, nachdem sie erstellt wurden in einem Unterordner `terraform.tfstate.d/` und heißen dann z.B. `test_euw1/terraform.tfstate`   

## lokales Testen
Dieses Repository enthält die Möglichkeit, Terraform in localstack zu verwenden.   
Es gibt ein docker-compose um localstack und terraform in einem Container zu starten.   
Terraform als Container-Service, damit man es nicht lokal installieren muss.   
Eine kleiner Golang-Webservice ist auch enthalten, damit man die Infrastruktur auch direkt testen kann. `./app/` enthält den Code für diesen Webservice.   
Im Docker compose wird das working directory auf das lokale Verzeichnis gemappt.
Dafür gibt es den Unterordner `terraform_localstack/` mit der terraform config.  

```
┌─────────────────────────────────────────────────────────┐
│                    docker-compose                       │
│                                                         │
│  ┌──────────┐    POST /upload    ┌──────────────────┐   │
│  │  Client  │──────────────────► │   Go App :8080   │   │
│  └──────────┘                    └────────┬─────────┘   │
│                                          │              │
│                          ┌───────────────┼──────────┐   │
│                          │               │          │   │
│                          ▼               ▼          │   │
│                   ┌──────────┐   ┌────────────┐     │   │
│                   │LocalStack│   │ PostgreSQL │     │   │
│                   │  S3      │   │  :5432     │     │   │
│                   │  SSM     │   └────────────┘     │   │
│                   │  Secrets │                      │   │
│                   │  IAM     │                      │   │
│                   └──────────┘                      │   │
└─────────────────────────────────────────────────────────┘
```

### Alles ausführen:  
```bash
make start-all
```
Startet localstack, initialisiert terraform, erstellt den Infrastruktur-Plan und führt ihn aus.  
Danach wird die app gebaut und gestartet. Localstack und die App befinden sich dann in einem gemeinsamen Container und können miteinander kommunizieren.   
ECR und ECS sind aus localstack Lizenzgründen nicht verfügbar, deswegen wird die App als Docker Container gestartet und mit einem Port verbunden.   

### Einzeln ausführen:

Docker starten:
```bash
make start
```

Docker beenden:
```bash
make stop
```

Terraform initialisieren:
```bash
make tf-local-init
```

Terraform Plan erstellen:
```bash
make tf-local-plan
```

Terraform ausführen:
```bash
make tf-local-apply
```

Workspace erstellen:
```bash
make create-workspace NAME=test_euw1
```

Workspace auswählen:
```bash
make create-workspace NAME=test_euw1
```

# Wichtige Blocktypen

| Block       | Zweck                                                                                                  |
|-------------|--------------------------------------------------------------------------------------------------------|
| `terraform` | Terraform selbst konfigurieren, z.B. benötigte Provider oder Terraform Version etc.                    |
| `provider`  | Verbindung zu APIs/Clouds, z.B. AWS, Azure etc.                                                        |
| `resource`  | Infrastruktur erstellen/verändern. Beschreibt, was man erstellen will, z.B. S3, Datenbank, Server etc. |
| `data`      | Bestehende Daten lesen ohne etwas neues zu erstellen                                                   |
| `variable`  | Eingaben definieren z.B. variable "region" ... -> region = var.region                                  |
| `output`    | Werte nach apply ausgeben, z.B. IP-Adresse                                                             |
| `locals`    | Definiert lokale Hilfsvariablen für Wiederverwendung oder Berechnung                                   |
| `module`    | Wiederverwendbare Komponenten                                                                          |
| `check`     | Ermöglicht Validierung während der Planung oder Ausführung                                             |
| `import`    | importiert bestehende Infrastruktur                                                                    |

# Wichtige Resource-Typen für AWS

| Resource                   | Warum wichtig         |
| -------------------------- | --------------------- |
| `aws_vpc`                  | Netzwerkbasis         |
| `aws_subnet`               | Netzwerksegmentierung |
| `aws_security_group`       | Firewall              |
| `aws_instance`             | Compute               |
| `aws_s3_bucket`            | Storage               |
| `aws_iam_role`             | Berechtigungen        |
| `aws_lb`                   | Lastverteilung        |
| `aws_db_instance`          | Datenbank             |
| `aws_route53_record`       | DNS                   |
| `aws_cloudwatch_log_group` | Logging               |


# Wichtige Expressions
TODO

# Grundaufbau HCL
```
block_type "<type>" "<frei wählbarer name>" {
	argument_name = expression
	nested_block{
		argument_name = expression
	}
}
```

Die resource Adresse wäre dann: <type>.<name>   
z.B. `aws_instance.web_server`

# Wichtige CLI Befehle

| Befehl          | Zweck                                        |
| --------------- | -------------------------------------------- |
| `terraform fmt` | Formatiert die HCL, also die .tf. Dateien    |
| `terraform init`  | Initialisert terraform und lädt alle Provider lokal herunter (zu finden in /.terraform)         |
| `terraform validate` | Prüfe ob dein terraform ist valide    |
| `terraform state list` | Zeigt alle resources und data sources an, die verwendet werden    |
| `terraform plan -out m3.tfplan` | Plan erstellen lassen    |
| `terraform show m3.tfplan` | Plan anzeigen lassen    |
| `terraform apply` | Plan ausführen    |
| `terraform destroy` | Infrastruktur löschen    |

# Best practices

Unterscheidung von Infrastruktur und Deployment:   
Man hat zwei Verzeichnisse:
- `./infrastructure/` – langlebige, selten ändernde Ressourcen
- `./deployment/` - häufig ändernde, release-spezifische Ressourcen

infrastructure Beispiel:  
Hier liegen Ressourcen, die einmal erstellt werden und sich kaum ändern:  
- VPC, Subnetze, Security Groups
- Datenbanken (z. B. RDS)
- IAM Roles/Policies
- Lambda-Funktionen (Hülle, nicht der Code)
- Load Balancer

deployment Beispiel:   
Hier liegen Ressourcen, die sich mit jedem Release ändern:
- Container-Image-Tags / Task Definitions (z. B. ECS)
- Lambda-Funktionscode (S3-Key des Deployments)
- Konfigurationswerte, die versioniert werden

Warum die Trennung?

| Grund | Erklärung |
|-------|-----------|
|Sicherheit|Infrastruktur-Änderungen sind riskant. Durch Trennung kann man verhindern, dass ein normaler Deploy versehentlich eine Security Group oder eine DB löscht.|
|Geschwindigkeit|terraform apply auf deployment ist schnell (wenige Ressourcen). infrastructure muss seltener angefasst werden.|
|State-Isolation|Jeder Ordner hat seinen eigenen Terraform State. Fehler im Deployment-State gefährden nicht den Infrastruktur-State.|
|Berechtigungen|CI/CD-Pipelines können für deployment andere (eingeschränktere) Rechte bekommen als für infrastructure.|
|Blast Radius|Ein Fehler im Deployment-Code kann nicht die gesamte Netzwerk-Infrastruktur zerstören.|

# TODO

- tfenv
