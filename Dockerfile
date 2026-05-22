# Stage 1: build the React frontend
FROM node:20-alpine AS frontend
WORKDIR /app/hubble
COPY hubble/package*.json ./
RUN npm install
COPY hubble/ ./
RUN npm run build

# Stage 2: Python backend + built frontend
FROM python:3.11-slim
WORKDIR /app

# Install system deps needed by pdfplumber / kaleido
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgl1 libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

COPY backend/requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY backend/ ./
# Copy React build into backend/dist so FastAPI can serve it
COPY --from=frontend /app/hubble/dist ./dist

RUN mkdir -p output

EXPOSE 8000
CMD ["python", "main.py"]
