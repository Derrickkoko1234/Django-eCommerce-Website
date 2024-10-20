# Define the base image with the desired Python version
ARG PYTHON_VERSION=3.12-slim-bullseye
FROM python:${PYTHON_VERSION}

# Environment variables to avoid writing .pyc files and to buffer output
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Install dependencies for psycopg2
RUN apt-get update && apt-get install -y \
    libpq-dev \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Create and set the working directory
RUN mkdir -p /code
WORKDIR /code

# Copy the requirements file and install dependencies
COPY requirements.txt /code/
RUN pip install --upgrade pip && pip install -r requirements.txt

# Copy the application code
COPY . /code/

# Set environment variables, e.g., SECRET_KEY should be set via environment during runtime for security
ENV SECRET_KEY "QQBgwRqAz3jMX2aLtvZ8HnDPYccdg6ML5ZhQ58TldsbhHrSBFX"

# Collect static files
RUN python manage.py migrate && python manage.py collectstatic --noinput

# Expose the application port
EXPOSE 8000

# Start the application using gunicorn
CMD ["gunicorn", "--bind", ":8000", "--workers", "2", "helpens.wsgi"]