#!/bin/bash

# Character Generator E2E Test Runner
echo "🚀 Character Generator E2E Test Runner"
echo "======================================="

# Check if required files exist
if [ ! -f "card.json" ]; then
    echo "❌ Error: card.json not found in current directory"
    exit 1
fi

if [ ! -f "IDENTITY.md" ]; then
    echo "❌ Error: IDENTITY.md not found in current directory"
    exit 1
fi

# Check if frontend is running
echo "🔍 Checking if frontend is running on localhost:8080..."
if ! curl -s http://localhost:8080 > /dev/null; then
    echo "❌ Error: Frontend not running on localhost:8080"
    echo "Please start the frontend server first"
    exit 1
fi

# Check if backend is running
echo "🔍 Checking if backend is running on localhost:8001..."
if ! curl -s http://localhost:8001/api/v2/system/health > /dev/null; then
    echo "❌ Error: Backend not running on localhost:8001"
    echo "Please start the backend server first"
    exit 1
fi

echo "✅ Both servers are running"

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    npm install
fi

# Install Playwright browsers if needed
if [ ! -d "node_modules/@playwright" ]; then
    echo "🌐 Installing Playwright browsers..."
    npx playwright install
fi

# Run the test
echo "🧪 Running Character Generation E2E Test..."
echo ""

# Choose test mode based on argument
case "$1" in
    "ui")
        npx playwright test --ui
        ;;
    "headed")
        npx playwright test --headed
        ;;
    "debug")
        npx playwright test --debug
        ;;
    *)
        npx playwright test
        ;;
esac

echo ""
echo "🎉 Test completed! Check the results above."
echo ""
echo "Available options:"
echo "  ./run-test.sh        - Run tests headless (default)"
echo "  ./run-test.sh ui     - Run with Playwright UI"
echo "  ./run-test.sh headed - Run with visible browser"
echo "  ./run-test.sh debug  - Run in debug mode"