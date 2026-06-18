package handler

import (
	"fmt"
	"net/http"

	awslib "aws-learning-service/internal/aws"

	"github.com/aws/aws-sdk-go-v2/service/s3"
	"github.com/google/uuid"
)

type UploadHandler struct {
	Bucket string
	S3     *s3.Client
}

func (h *UploadHandler) Upload(
	w http.ResponseWriter,
	r *http.Request,
) {

	file, _, err := r.FormFile("file")
	if err != nil {
		http.Error(w, err.Error(), 400)
		return
	}

	defer file.Close()

	key := uuid.New().String()

	err = awslib.Upload(
		r.Context(),
		h.S3,
		h.Bucket,
		key,
		file,
	)

	if err != nil {
		http.Error(w, err.Error(), 500)
		return
	}

	fmt.Fprintf(w, "uploaded: %s", key)
}
