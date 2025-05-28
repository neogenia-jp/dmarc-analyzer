FROM ruby:3.4.4

# 必要なパッケージをインストール
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libcurl4-openssl-dev \
    libssl-dev \
    libffi-dev \
    && rm -rf /var/lib/apt/lists/*

# 必要な gem をインストール
RUN gem install googleauth google-apis-gmail_v1 fileutils

# 作業ディレクトリに移動
WORKDIR /app
