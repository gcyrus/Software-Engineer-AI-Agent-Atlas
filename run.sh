#!/bin/bash

# Parse command line arguments
RUN_BACKEND=false
RUN_FRONTEND=false
FOLLOW_LOGS=false

while getopts "bfh" opt; do
    case ${opt} in
        b )
            RUN_BACKEND=true
            ;;
        f )
            RUN_FRONTEND=true
            ;;
        h )
            echo "Usage: $0 [-b] [-f]"
            echo "  -b    Run the backend API"
            echo "  -f    Run the frontend UI"
            echo "  -h    Display this help message"
            echo ""
            echo "Examples:"
            echo "  $0 -b      # Run backend only"
            echo "  $0 -f      # Run frontend only"
            echo "  $0 -b -f   # Run both backend and frontend"
            exit 0
            ;;
        \? )
            echo "Invalid option: -$OPTARG" 1>&2
            echo "Use -h for help"
            exit 1
            ;;
    esac
done

# If no options provided, show help
if [ "$RUN_BACKEND" = false ] && [ "$RUN_FRONTEND" = false ]; then
    echo "Error: No service specified to run"
    echo "Use -b for backend API, -f for frontend UI, or both"
    echo "Use -h for help"
    exit 1
fi

# Create logs directory if it doesn't exist
mkdir -p logs

# Clear shutdown script if it exists
> shutdown.sh

# Track what logs to follow
LOGS_TO_FOLLOW=""

# Start Character Card Generator API if requested
if [ "$RUN_BACKEND" = true ]; then
    source REPOS/character-card-generator-api/.venv/bin/activate
    cd REPOS/character-card-generator-api
    nohup python -m uvicorn card_generator_app.api.main:app --reload --host 0.0.0.0 --port 8000 > ../../logs/character_card_generator_api.log 2>&1 &
    cd ../..
    echo "Character Card Generator API is running in the background on port 8000."
    echo "Logs are being written to logs/character_card_generator_api.log"
    echo "To stop the server, use: kill \$(pgrep -f 'uvicorn card_generator_app.api.main:app')"
    echo "kill \$(pgrep -f 'uvicorn card_generator_app.api.main:app')" >> shutdown.sh
    echo "To view the logs, use: tail -f logs/character_card_generator_api.log"
    echo ""
    LOGS_TO_FOLLOW="$LOGS_TO_FOLLOW logs/character_card_generator_api.log"
fi

# Start CardForge AI Studio if requested
if [ "$RUN_FRONTEND" = true ]; then
    cd REPOS/cardforge-ai-studio
    nohup npm run dev > ../../logs/cardforge_ai_studio.log 2>&1 &
    cd ../..
    echo "CardForge AI Studio is running in the background."
    echo "Logs are being written to logs/cardforge_ai_studio.log"
    echo "To stop the server, use: kill \$(pgrep -f 'npm run dev')"
    echo "kill \$(pgrep -f 'npm run dev')" >> shutdown.sh
    echo "To view the logs, use: tail -f logs/cardforge_ai_studio.log"
    echo ""
    LOGS_TO_FOLLOW="$LOGS_TO_FOLLOW logs/cardforge_ai_studio.log"
fi

# Make shutdown script executable
chmod +x shutdown.sh

# Show logs if any services were started
if [ -n "$LOGS_TO_FOLLOW" ]; then
    echo "Following logs for started services..."
    tail -f $LOGS_TO_FOLLOW
fi