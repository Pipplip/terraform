package database

import (
	"context"
)

func Connect(
	ctx context.Context,
	connString string,
) (*pgx.Conn, error) {

	return pgx.Connect(ctx, connString)
}
