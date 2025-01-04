package server

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"strconv"
	"time"

	_ "github.com/joho/godotenv/autoload"

	"skyllago/internal/database"
)

// Server wraps the HTTP server and dependencies like the database.
type Server struct {
	port int
	db   database.Database
}

// NewServer initializes a new Server instance and returns an HTTP server.
func NewServer() *http.Server {
	// Load the port from environment variables with a default fallback.
	portStr := os.Getenv("PORT")
	port, err := strconv.Atoi(portStr)
	if err != nil || port <= 0 {
		log.Printf("Invalid PORT environment variable '%s', defaulting to 8080", portStr)
		port = 8080
	}

	// Initialize the database
	db := database.New()

	// Initialize the custom Server
	s := &Server{
		port: port,
		db:   db,
	}

	// Create the HTTP server with configurations
	server := &http.Server{
		Addr:         fmt.Sprintf(":%d", s.port),
		Handler:      s.RegisterRoutes(), // Register server routes
		IdleTimeout:  time.Minute,
		ReadTimeout:  10 * time.Second,
		WriteTimeout: 30 * time.Second,
	}

	return server
}
