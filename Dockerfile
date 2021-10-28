FROM ruby:2.7.2
ENV BUNDLER_VESION=1.17.3 \
    APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1 \
    TIME_ZONE='Asia/Tokyo'

# Get Source
## Node.js 
RUN curl -sL https://deb.nodesource.com/setup_14.x -o nodesource_setup.sh \
    && bash nodesource_setup.sh

## yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

## other
### chrome (for spec)
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add \
    && echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | tee /etc/apt/sources.list.d/google-chrome.list

### google driver

# apt setup
RUN apt-get update \
    && apt-get install -y \
    nodejs \
    yarn \
    google-chrome-stable \
    vim \
    libnss3 \
    libgconf-2-4

# Copy Directory 
RUN mkdir /lds
WORKDIR  /lds
COPY . /lds 

# Install Bundler & Install gems 
RUN gem install bundler -v $BUNDLER_VESION \
    && bundle install

# Install node modules
#RUN yarn upgrade \
#    yarn install 

# If webpack cannot be installed with yarn...
# Please uncomment the following and execute "docekr-compose build & up"
# ex) int the Vagrant enviroment, you can't make a symlink.
#RUN npm install -g npm \
#    && rm -rf ./node_modules \
#    && npm install \
#    && npm install -g webpack-cli

# exec shell
COPY ./shell/entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0"]


