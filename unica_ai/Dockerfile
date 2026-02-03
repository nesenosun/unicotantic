FROM python:3.9-slim

WORKDIR /app

# Sistem bağımlılıklarını yükle (Gerekirse)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Gereksinimleri kopyala ve yükle
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Uygulama kodlarını kopyala
COPY . .

# Veritabanı için klasör oluştur
RUN mkdir -p memory

# Portu dışa aç
EXPOSE 8000

# Uygulamayı başlat
CMD ["uvicorn", "api:app", "--host", "0.0.0.0", "--port", "8000"]
