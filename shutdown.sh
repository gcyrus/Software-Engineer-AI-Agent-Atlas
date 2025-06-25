kill $(pgrep -f 'uvicorn card_generator_app.api.main:app')
kill $(pgrep -f 'npm run dev')
