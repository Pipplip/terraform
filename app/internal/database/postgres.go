package database

import (
	"context"

	"github.com/jackc/pgx/v5"
)

func Connect(
	ctx context.Context,
	connString string,
) (*pgx.Conn, error) {

	return pgx.Connect(ctx, connString)
}
