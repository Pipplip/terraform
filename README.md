# Terraform

https://developer.hashicorp.com/terraform/tutorials/aws-get-started/aws-manage

## Allgemein
- Infrastruktur wird deklarativ verwaltet als Code
- man definiert eine Infrastuktur und terraform setzt sie um
- HCL ist die Konfigurationssprache (HCL: HashiCorp Config Language)
- Terraform hält den aktuellen Zustand deiner Infrastruktur in einer Datei terraform.tfstate
(Damit weiß terraform was existiert und was geändert werden muss)

Terraform init liest nur .tf Dateien im Root Verzeichnis, nicht in Subdirectories

## Deploy infrastructure
1. Scope: Infrastruktur identifizieren (was wird benötigt?)
2. Author: Schreibe die Konfiguration für die Infrastruktur
3. Initialize: Installiere alle benötigten Terraform provider
4. Plan: Analysiere die Vorschau
5. Apply: Führe Plan aus

## terraform.tf erstellen
Diese Datei konfiguriert terraform selbst.   
Also z.B. Version oder benötigte Provider (z.B. AWS)    

## main.tf erstellen
Hier wird der Provider selbst konfiguriert.   

## terraform init
Dieses Befehl in der Console ausführen, damit Terraform initialisiert wird, mit den Configs von oben.   

## terraform.tfstate
Enthält den aktuellen Zustand + Metadaten.   
Diese Datei ist sehr wichtig und sollte nicht manuell geändert werden.   
Sie entsteht nachdem `terraform apply` ausgeführt wurde.   
Diese Datei enthält auch sensitive Daten wie Passwörter!   

## lokales Testen
Dieses Repository enthält die Möglichkeit, Terraform in localstack zu verwenden.   
Es gibt ein docker-compose um localstack und terraform in einem Container zu starten.   
Terraform als Service, damit man es nicht lokal installieren muss.   

Dafür gibt es den Unterordner `terraform_localstack/` mit der terraform config.   

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

## CLI ausführen


# Wichtige Blocktypen

| Block       | Zweck                             |
| ----------- | --------------------------------- |
| `terraform` | Terraform selbst konfigurieren    |
| `provider`  | Verbindung zu APIs/Clouds, z.B. AWS, Azure etc.         |
| `resource`  | Infrastruktur erstellen/verändern. Beschreibt, was man erstellen will, z.B. Datenbank, Server etc. |
| `data`      | Bestehende Daten lesen            |
| `variable`  | Eingaben definieren               |
| `output`    | Werte nach apply ausgeben, z.B. IP-Adresse   |
| `locals`    | Hilfsvariablen                    |
| `module`    | Wiederverwendbare Komponenten     |

# Wichtige Expressions


# Grundaufbau HCL
```
block_type "<type>" "<name>" {
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

