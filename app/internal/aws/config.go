package aws

import (
	"context"
	"os"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
)

func NewConfig(ctx context.Context) (*aws.Config, error) {

	endpoint := os.Getenv("AWS_ENDPOINT_URL")

	cfg, err := config.LoadDefaultConfig(ctx,
		config.WithRegion("eu-west-1"),
		config.WithCredentialsProvider(
			aws.NewCredentialsCache(
				aws.CredentialsProviderFunc(func(ctx context.Context) (aws.Credentials, error) {
					return aws.Credentials{
						AccessKeyID:     "test",
						SecretAccessKey: "test",
					}, nil
				}),
			),
		),
	)
	if err != nil {
		return nil, err
	}

	// 👇 DAS ist der entscheidende Teil
	cfg.BaseEndpoint = aws.String(endpoint)

	return &cfg, nil
}
