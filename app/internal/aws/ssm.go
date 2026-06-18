package aws

import (
	"context"

	"github.com/aws/aws-sdk-go-v2/service/ssm"
)

func GetParameter(
	ctx context.Context,
	client *ssm.Client,
	name string,
) (string, error) {

	result, err := client.GetParameter(ctx, &ssm.GetParameterInput{
		Name: &name,
	})

	if err != nil {
		return "", err
	}

	return *result.Parameter.Value, nil
}
