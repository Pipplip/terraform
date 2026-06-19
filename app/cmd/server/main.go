package main

import (
	"aws-learning-service/internal/database"
	"aws-learning-service/internal/handler"
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"

	awslib "aws-learning-service/internal/aws"

	"github.com/aws/aws-sdk-go-v2/service/s3"
	"github.com/aws/aws-sdk-go-v2/service/secretsmanager"
	"github.com/aws/aws-sdk-go-v2/service/ssm"
)

type DBSecret struct {
	Username string `json:"username"`
	Password string `json:"password"`
}

func main() {

	ctx := context.Background()

	// AWS config laden, auch die IAM Rolle
	cfg, err := awslib.NewConfig(ctx)
	if err != nil {
		log.Fatal(err)
	}

	// greife auf die SSM Konfigurations-Parameter zu
	ssmClient := ssm.NewFromConfig(*cfg)

	// greife auf die secrets.tf zu
	secretsClient := secretsmanager.NewFromConfig(*cfg)
	s3Client := s3.NewFromConfig(*cfg, func(o *s3.Options) {
		o.UsePathStyle = true
	})

	workspace := os.Getenv("TF_WORKSPACE")
	log.Println("workspace:", workspace)

	// App fragt nach SSM, AWS prüft die Policy (app-role).
	// Also darf die App das haben.
	// Ist in iam.tf definiert mit actions = ["ssm:GetParameter"] - also OK
	bucket, err := awslib.GetParameter(
		ctx,
		ssmClient,
		fmt.Sprintf("/%s/app/s3/bucket", workspace),
	)
	if err != nil {
		log.Fatal(err)
	}

	dbHost, err := awslib.GetParameter(
		ctx,
		ssmClient,
		fmt.Sprintf("/%s/app/db/host", workspace),
	)
	if err != nil {
		log.Fatal(err)
	}

	// hole secret aus secret.tf und parst JSON in DBSecret
	// Bevor secret geholt wird, wird geprüft on die app das Recht hat
	// In iam.tf ist sie definiert actions   = ["secretsmanager:GetSecretValue"] - also OK
	secretString, err := awslib.GetSecret(
		ctx,
		secretsClient,
		fmt.Sprintf("%s/app/database", workspace),
	)
	if err != nil {
		log.Fatal(err)
	}

	var secret DBSecret

	err = json.Unmarshal(
		[]byte(secretString),
		&secret,
	)
	if err != nil {
		log.Fatal(err)
	}

	// DB-Verbindung aufbauen
	connString := fmt.Sprintf(
		"postgres://%s:%s@%s:5432/uploads",
		secret.Username, secret.Password, dbHost,
	)
	db, err := database.Connect(ctx, connString)
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close(ctx)

	log.Println("bucket:", bucket)
	log.Println("db host:", dbHost)
	log.Println("db user:", secret.Username)

	h := &handler.UploadHandler{
		Bucket: bucket,
		S3:     s3Client,
		DB:     db,
	}

	http.HandleFunc(
		"/upload",
		h.Upload,
	)

	log.Println("listening :8080")

	log.Fatal(
		http.ListenAndServe(
			":8080",
			nil,
		),
	)
}
