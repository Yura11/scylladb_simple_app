package database

import (
	"context"
	"fmt"
	"log"
	"os"
	"strings"
	"time"

	"github.com/gocql/gocql"
	_ "github.com/joho/godotenv/autoload"
)

// Database interface defines the required database operations.
type Database interface {
	Health() map[string]string
	Close() error
	RegisterUser(username, password string) error
	GetPassword(username string) (string, error)
}

// service is the concrete implementation of the Database interface.
type service struct {
	Session *gocql.Session
}

// Environment variables for ScyllaDB connection.
var (
	hosts            = os.Getenv("BLUEPRINT_DB_HOSTS")       // Comma-separated list of hosts
	username         = os.Getenv("BLUEPRINT_DB_USERNAME")    // Database username
	password         = os.Getenv("BLUEPRINT_DB_PASSWORD")    // Database password
	consistencyLevel = os.Getenv("BLUEPRINT_DB_CONSISTENCY") // Consistency level
	keyspace         = os.Getenv("BLUEPRINT_DB_KEYSPACE")    // Keyspace name
)

// New initializes a new Database service with a ScyllaDB session.
func New() Database {
	cluster := gocql.NewCluster(strings.Split(hosts, ",")...)
	cluster.PoolConfig.HostSelectionPolicy = gocql.TokenAwareHostPolicy(gocql.RoundRobinHostPolicy())

	// Set authentication if provided
	if username != "" && password != "" {
		cluster.Authenticator = gocql.PasswordAuthenticator{
			Username: username,
			Password: password,
		}
	}

	// Set consistency level if specified
	if consistencyLevel != "" {
		if cl, err := parseConsistency(consistencyLevel); err == nil {
			cluster.Consistency = cl
		} else {
			log.Printf("Invalid consistency level '%s', using default. Error: %v", consistencyLevel, err)
		}
	}

	// Create a session for the system keyspace to perform admin tasks
	cluster.Keyspace = "system"
	session, err := cluster.CreateSession()
	if err != nil {
		log.Fatalf("Failed to connect to ScyllaDB cluster: %v", err)
	}
	defer session.Close()

	// Ensure the keyspace exists
	if err := ensureKeyspaceExists(session, keyspace); err != nil {
		log.Fatalf("Failed to initialize keyspace: %v", err)
	}

	// Configure a new session for the application keyspace
	cluster.Keyspace = keyspace
	cluster.PoolConfig.HostSelectionPolicy = gocql.TokenAwareHostPolicy(gocql.RoundRobinHostPolicy())
	appSession, err := cluster.CreateSession()
	if err != nil {
		log.Fatalf("Failed to connect to keyspace '%s': %v", keyspace, err)
	}

	// Ensure required tables exist
	if err := createTables(appSession); err != nil {
		log.Fatalf("Failed to initialize database schema: %v", err)
	}

	return &service{Session: appSession}
}

// parseConsistency converts a consistency level string to a gocql.Consistency value.
func parseConsistency(cons string) (gocql.Consistency, error) {
	consistencyMap := map[string]gocql.Consistency{
		"ANY":          gocql.Any,
		"ONE":          gocql.One,
		"TWO":          gocql.Two,
		"THREE":        gocql.Three,
		"QUORUM":       gocql.Quorum,
		"ALL":          gocql.All,
		"LOCAL_ONE":    gocql.LocalOne,
		"LOCAL_QUORUM": gocql.LocalQuorum,
		"EACH_QUORUM":  gocql.EachQuorum,
	}

	consistency, ok := consistencyMap[strings.ToUpper(cons)]
	if !ok {
		return gocql.LocalQuorum, fmt.Errorf("unknown consistency level: %s", cons)
	}
	return consistency, nil
}

// createTables ensures that required tables exist in the database.
func createTables(session *gocql.Session) error {
	createUsersTableQuery := `
		CREATE TABLE IF NOT EXISTS users (
			username TEXT PRIMARY KEY,
			password TEXT
		);
	`

	if err := session.Query(createUsersTableQuery).Exec(); err != nil {
		return fmt.Errorf("failed to create 'users' table: %v", err)
	}

	return nil
}

// Health checks the database connection and returns its status.
func (s *service) Health() map[string]string {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	stats := map[string]string{}
	startedAt := time.Now()

	// Execute a simple query to check connectivity
	query := "SELECT now() FROM system.local"
	var currentTime time.Time
	if err := s.Session.Query(query).WithContext(ctx).Scan(&currentTime); err != nil {
		stats["status"] = "down"
		stats["message"] = fmt.Sprintf("Health check failed: %v", err)
		return stats
	}

	stats["status"] = "up"
	stats["message"] = "Database is healthy"
	stats["scylla_current_time"] = currentTime.String()
	stats["health_check_duration"] = time.Since(startedAt).String()
	return stats
}

func ensureKeyspaceExists(session *gocql.Session, keyspace string) error {
	if keyspace == "" {
		return fmt.Errorf("keyspace is not specified in 'BLUEPRINT_DB_KEYSPACE'")
	}

	createKeyspaceQuery := fmt.Sprintf(`
		CREATE KEYSPACE IF NOT EXISTS %s
		WITH replication = {
			'class': 'SimpleStrategy',
			'replication_factor': 3
		};
	`, keyspace)

	if err := session.Query(createKeyspaceQuery).Exec(); err != nil {
		return fmt.Errorf("failed to create keyspace '%s': %v", keyspace, err)
	}
	return nil
}

func (s *service) RegisterUser(username, password string) error {
	query := "INSERT INTO users (username, password) VALUES (?, ?)"
	if err := s.Session.Query(query, username, password).Exec(); err != nil {
		return fmt.Errorf("failed to register user '%s': %v", username, err)
	}
	return nil
}

func (s *service) GetPassword(username string) (string, error) {
	var password string
	query := "SELECT password FROM users WHERE username = ?"
	if err := s.Session.Query(query, username).Scan(&password); err != nil {
		if err == gocql.ErrNotFound {
			return "", fmt.Errorf("user '%s' not found", username)
		}
		return "", fmt.Errorf("failed to fetch password for user '%s': %v", username, err)
	}
	return password, nil
}

// Close terminates the database session.
func (s *service) Close() error {
	s.Session.Close()
	return nil
}
