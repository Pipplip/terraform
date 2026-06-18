package aws

import (
	"context"
	"io"

	"github.com/aws/aws-sdk-go-v2/service/s3"
)

func Upload(
	ctx context.Context,
	client *s3.Client,
	bucket string,
	key string,
	body io.Reader,
) error {

	_, err := client.PutObject(
		ctx,
		&s3.PutObjectInput{
			Bucket: &bucket,
			Key:    &key,
			Body:   body,
		},
	)

	return err
}
