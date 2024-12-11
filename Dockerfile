
FROM python:3.10-slim

WORKDIR /app

RUN pip install django==3.2

COPY requirements.txt .


RUN pip install --no-cache-dir  -r requirements.txt

COPY . .


EXPOSE 8000


CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]

