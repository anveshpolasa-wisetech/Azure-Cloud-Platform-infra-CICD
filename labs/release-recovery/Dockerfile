FROM python:3.12-slim-bookworm
WORKDIR /app
COPY --chown=10001:10001 app.py .
USER 10001:10001
EXPOSE 8080
CMD ["python", "-B", "app.py"]
