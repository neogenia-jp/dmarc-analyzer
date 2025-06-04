FROM ruby:3.4.4

# 必要なパッケージをインストール
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libcurl4-openssl-dev \
    libssl-dev \
    libffi-dev \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# 必要な gem をインストール
RUN gem install googleauth google-apis-gmail_v1 fileutils

# タイムゾーン設定
ENV TZ=Asia/Tokyo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 作業ディレクトリに移動
WORKDIR /app
