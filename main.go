package main

import "fmt"

// Version information
const Version = "v0.1.0"

// App represents the main application
type App struct {
	Name    string
	Version string
}

// NewApp creates a new application instance
func NewApp(name string) *App {
	return &App{
		Name:    name,
		Version: Version,
	}
}

// Start starts the application
func (a *App) Start() error {
	fmt.Printf("Starting %s %s\n", a.Name, a.Version)
	return nil
}

// Add adds two numbers
func Add(a, b int) int {
	return a + b
}

// Multiply multiplies two numbers
func Multiply(a, b int) int {
	return a * b
}
