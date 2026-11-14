FROM python:3.12-slim

# Run as a non-root user
RUN useradd --create-home --uid 10001 app
WORKDIR /app
COPY app.py .
USER app

ENV PORT=8080
EXPOSE 8080

CMD ["python", "app.py"]
