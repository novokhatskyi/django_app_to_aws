# Use the official Python runtime image
FROM python:3.13-slim

# Create the app directory
RUN mkdir /app

# Set the working directory inside the container
WORKDIR /app

# Set environment variables
# Prevents Python from writing pyc files to disk
ENV PYTHONDONTWRITEBYTECODE=1
#Prevents Python from buffering stdout and stderr
ENV PYTHONUNBUFFERED=1

# Upgrade pip
RUN pip install --upgrade pip

# Copy the requirements file first (better caching)
COPY requirements.txt  /app/

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the Django project to the container
COPY . /app/

# Collect static files (CSS/JS for admin) into STATIC_ROOT
RUN python manage.py collectstatic --noinput

# Expose the application port
EXPOSE 8000

# Run Django’s development server
#CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
# Run the app with Gunicorn (production WSGI server)
CMD ["gunicorn", "django_app.wsgi:application", "--bind", "0.0.0.0:8000", "--workers", "2", "--access-logfile", "-"]