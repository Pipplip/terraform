package aws

import (
	"context"

	"github.com/aws/aws-sdk-go-v2/service/secretsmanager"
)

func GetSecret(
	ctx context.Context,
	client *secretsmanager.Client,
	name string,
) (string, error) {

	result, err := client.GetSecretValue(
		ctx,
		&secretsmanager.GetSecretValueInput{
			SecretId: &name,
		},
	)

	if err != nil {
		return "", err
	}

	return *result.SecretString, nil
}
