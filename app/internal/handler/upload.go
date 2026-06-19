package handler

import (
	"fmt"
	"net/http"

	awslib "aws-learning-service/internal/aws"

	"github.com/aws/aws-sdk-go-v2/service/s3"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
)

type UploadHandler struct {
	Bucket string
	S3     *s3.Client
	DB     *pgx.Conn
}

func (h *UploadHandler) Upload(
	w http.ResponseWriter,
	r *http.Request,
) {

	file, header, err := r.FormFile("file")
	if err != nil {
		http.Error(w, err.Error(), 400)
		return
	}

	defer file.Close()

	key := uuid.New().String()

	// S3 Upload
	// Hier wird geprüft ob Upload erlaubt ist
	// in iam.tf ["s3:PutObject", "s3:GetObject"] - also OK
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

	// Postgres upload
	_, err = h.DB.Exec(r.Context(),
		"INSERT INTO uploads (key, filename, uploaded_at) VALUES ($1, $2, NOW())",
		key, header.Filename,
	)

	if err != nil {
		http.Error(w, err.Error(), 500)
		return
	}

	fmt.Fprintf(w, "uploaded: %s", key)
}
