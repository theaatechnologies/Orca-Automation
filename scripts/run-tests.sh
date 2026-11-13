#!/bin/bash
# Automated test runner script for Workshop environments

set -e

TEST_TYPE=${1:-all}
RESULTS_DIR="test-results"
FAILED=0   # set to 1 by any failing test command (linters stay advisory)

echo "=========================================="
echo "Running tests in Workshop environment"
echo "Test type: $TEST_TYPE"
echo "=========================================="

# Create results directory
mkdir -p "$RESULTS_DIR"

# Function to run Go tests
run_go_tests() {
    echo "Running Go tests..."
    if [ -f "go.mod" ]; then
        # Unit tests
        if [ "$TEST_TYPE" = "unit" ] || [ "$TEST_TYPE" = "all" ]; then
            echo "Running Go unit tests..."
            go test ./... -v -race -coverprofile="$RESULTS_DIR/go-coverage.out" \
                -covermode=atomic -json > "$RESULTS_DIR/go-unit-tests.json" || FAILED=1
            go tool cover -html="$RESULTS_DIR/go-coverage.out" -o "$RESULTS_DIR/go-coverage.html"
        fi
        
        # Integration tests
        if [ "$TEST_TYPE" = "integration" ] || [ "$TEST_TYPE" = "all" ]; then
            echo "Running Go integration tests..."
            go test -tags=integration ./... -v > "$RESULTS_DIR/go-integration-tests.log" || FAILED=1
        fi
    else
        echo "No go.mod found, skipping Go tests"
    fi
}

# Function to run Node.js tests
run_node_tests() {
    echo "Running Node.js tests..."
    if [ -f "package.json" ]; then
        # Install dependencies if needed
        if [ ! -d "node_modules" ]; then
            echo "Installing Node.js dependencies..."
            npm install
        fi
        
        # Unit tests
        if [ "$TEST_TYPE" = "unit" ] || [ "$TEST_TYPE" = "all" ]; then
            echo "Running Node.js unit tests..."
            npm test -- --coverage --json --outputFile="$RESULTS_DIR/node-unit-tests.json" || FAILED=1
        fi
        
        # Integration tests
        if [ "$TEST_TYPE" = "integration" ] || [ "$TEST_TYPE" = "all" ]; then
            echo "Running Node.js integration tests..."
            npm run test:integration > "$RESULTS_DIR/node-integration-tests.log" 2>&1 || FAILED=1
        fi
    else
        echo "No package.json found, skipping Node.js tests"
    fi
}

# Function to run linters
run_linters() {
    echo "Running linters..."
    
    # Go linting
    if [ -f "go.mod" ]; then
        if command -v golangci-lint &> /dev/null; then
            golangci-lint run --out-format json > "$RESULTS_DIR/go-lint.json" || true
        fi
    fi
    
    # JavaScript linting
    if [ -f "package.json" ]; then
        if [ -f ".eslintrc.js" ] || [ -f ".eslintrc.json" ]; then
            npm run lint -- --format json --output-file "$RESULTS_DIR/eslint.json" || true
        fi
    fi
}

# Function to generate test summary
generate_summary() {
    echo "Generating test summary..."
    cat > "$RESULTS_DIR/summary.txt" << EOF
========================================
Test Execution Summary
========================================
Test Type: $TEST_TYPE
Timestamp: $(date -u +"%Y-%m-%d %H:%M:%S UTC")
Environment: Workshop

Test Results:
EOF

    if [ -f "$RESULTS_DIR/go-unit-tests.json" ]; then
        echo "  - Go unit tests: COMPLETED" >> "$RESULTS_DIR/summary.txt"
    fi
    
    if [ -f "$RESULTS_DIR/node-unit-tests.json" ]; then
        echo "  - Node.js unit tests: COMPLETED" >> "$RESULTS_DIR/summary.txt"
    fi
    
    echo "" >> "$RESULTS_DIR/summary.txt"
    echo "Results saved to: $RESULTS_DIR/" >> "$RESULTS_DIR/summary.txt"
    
    cat "$RESULTS_DIR/summary.txt"
}

# Main execution
main() {
    case $TEST_TYPE in
        unit|integration|all)
            run_go_tests
            run_node_tests
            run_linters
            generate_summary
            ;;
        *)
            echo "Unknown test type: $TEST_TYPE"
            echo "Usage: $0 [unit|integration|all]"
            exit 1
            ;;
    esac
    
    echo ""
    echo "=========================================="
    echo "Test execution completed: $([ "$FAILED" = 0 ] && echo PASSED || echo FAILED)"
    echo "=========================================="
}

main
exit "$FAILED"
