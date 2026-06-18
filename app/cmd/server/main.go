package main

import (
	"aws-learning-service/internal/handler"
	"context"
	"encoding/json"
	"log"
	"net/http"

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

	cfg, err := awslib.NewConfig(ctx)
	if err != nil {
		log.Fatal(err)
	}

	ssmClient := ssm.NewFromConfig(*cfg)
	secretsClient := secretsmanager.NewFromConfig(*cfg)
	s3Client := s3.NewFromConfig(*cfg, func(o *s3.Options) {
		o.UsePathStyle = true
	})

	bucket, err := awslib.GetParameter(
		ctx,
		ssmClient,
		"/app/s3/bucket",
	)
	if err != nil {
		log.Fatal(err)
	}

	dbHost, err := awslib.GetParameter(
		ctx,
		ssmClient,
		"/app/db/host",
	)
	if err != nil {
		log.Fatal(err)
	}

	secretString, err := awslib.GetSecret(
		ctx,
		secretsClient,
		"app/database",
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

	log.Println("bucket:", bucket)
	log.Println("db host:", dbHost)
	log.Println("db user:", secret.Username)

	h := &handler.UploadHandler{
		Bucket: bucket,
		S3:     s3Client,
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
