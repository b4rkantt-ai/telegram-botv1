FROM python:3.11-slim

# Sistem bağımlılıklarını kur (ffmpeg + nodejs + npm + git)
RUN apt-get update && apt-get install -y \
    ffmpeg \
    nodejs \
    npm \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Node.js versiyonunu kontrol et (loglarda göreceksin)
RUN node --version && npm --version

# BGUtils POT Sağlayıcıyı klonla ve derle
RUN git clone --single-branch --branch 2.0.0 https://github.com/Brainicism/bgutil-ytdlp-pot-provider.git /app/bgutil-ytdlp-pot-provider \
    && cd /app/bgutil-ytdlp-pot-provider/server/ \
    && npm ci \
    && npx tsc

# Çalışma dizini
WORKDIR /app

# Proje dosyalarını kopyala
COPY . /app

# Python bağımlılıklarını kur
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir pyTelegramBotAPI yt-dlp requests Pillow

# yt-dlp versiyonunu kontrol et (loglarda göreceksin)
RUN yt-dlp --version

# Başlatma: POT sunucusunu arka planda başlat, 3 saniye bekle, botu çalıştır
CMD ["sh", "-c", "node /app/bgutil-ytdlp-pot-provider/server/build/main.js & sleep 3 && python 1-hotmail.py"]
