FROM phusion/passenger-ruby23:0.9.35
ENV HOME /home/app/webapp

# Add the nginx site and config

ADD webapp.conf /etc/nginx/sites-enabled/webapp.conf
ADD nginx.conf /etc/nginx/nginx.conf
ADD rails-env.conf /etc/nginx/main.d/rails-env.conf
RUN ln -sf /dev/stdout /var/log/nginx/access.log

# Start Nginx / Passenger
RUN rm -f /etc/service/nginx/down

# Remove the default site/
RUN rm /etc/nginx/sites-enabled/default

# install and use ruby-2.3.1
RUN bash -lc 'rvm install ruby-2.3.1'
RUN bash -lc 'rvm --default use ruby-2.3.1'

# install nodejs 8
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y nodejs

RUN apt-get update && \
apt-get install -y --fix-missing \
xvfb wget imagemagick \
acl adwaita-icon-theme at-spi2-core colord colord-data dconf-gsettings-backend dconf-service \
glib-networking glib-networking-common glib-networking-services gsettings-desktop-schemas humanity-icon-theme \
libasound2 libasound2-data libatk-bridge2.0-0 libatk1.0-0 libatk1.0-data libatspi2.0-0 libboost-filesystem1.58.0 \
libboost-system1.58.0 libcairo-gobject2 libcanberra0 libcapnp-0.5.3 libcolord2 libcolorhug2 libdbusmenu-glib4 \
libdbusmenu-gtk3-4 libdconf1 libegl1-mesa libepoxy0 libexif12 libgbm1 libgphoto2-6 libgphoto2-l10n libgphoto2-port12 \
libgtk-3-0 libgtk-3-bin libgtk-3-common libgudev-1.0-0 libgusb2 libieee1284-3 libjson-glib-1.0-0 \
libjson-glib-1.0-common libmirclient9 libmircommon7 libmircore1 libmirprotobuf3 libogg0 libpolkit-agent-1-0 \
libpolkit-backend-1-0 libpolkit-gobject-1-0 libprotobuf-lite9v5 libproxy1v5 librest-0.7-0 libsane libsane-common \
libsoup-gnome2.4-1 libsoup2.4-1 libstartup-notification0 libtdb1 libusb-1.0-0 libvorbis0a libvorbisfile3 \
libwayland-client0 libwayland-cursor0 libwayland-egl1-mesa libwayland-server0 libxcb-util1 libxcb-xfixes0 \
libxcomposite1 libxcursor1 libxi6 libxinerama1 libxkbcommon0 libxrandr2 libxtst6 policykit-1 \
sound-theme-freedesktop ubuntu-mono xul-ext-ubufox openjdk-8-jdk
# XVFB is needed since the image is headless and we need a Xserver to run Firefox on.
# wget is needed to download the archaic version of firefox that works with the locked selenium webdriver version
# imagemagick is needed for paperclip to resize the driver picture
# other packages are dependencies of firefox

RUN wget https://ftp.mozilla.org/pub/firefox/releases/46.0.1/linux-x86_64/en-US/firefox-46.0.1.tar.bz2

RUN tar -xjf firefox-46.0.1.tar.bz2

# Link our version of firefox
RUN mv firefox /opt/firefox4601
RUN chmod a+x /opt/firefox4601/firefox
RUN ln -s /opt/firefox4601/firefox /usr/bin/firefox

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

# Change permissions of app folder
ADD . /home/app/webapp
RUN chown -R app:app /home/app/webapp
WORKDIR /home/app/webapp

RUN wget http://mirrors.estointernet.in/apache//jmeter/binaries/apache-jmeter-5.1.1.tgz
RUN tar -xzf apache-jmeter-5.1.1.tgz

RUN ln -s /home/app/webapp/apache-jmeter-5.1.1/bin/jmeter /usr/bin/jmeter

ADD Gemfile /home/app/webapp/Gemfile
ADD Gemfile.lock /home/app/webapp/Gemfile.lock

#RUN bundle install
ENV BUNDLE_GEMFILE=/home/app/webapp/Gemfile \
  BUNDLE_JOBS=2 \
  BUNDLE_PATH=/bundle
RUN gem install bundler -v 2.0.1
RUN rvm-exec 2.3.1 bundle install

RUN npm install -g grunt-cli bower
RUN npm install && bower --allow-root install

#RUN cp config/initializers/devise_token_auth.rb config/initializers/devise_token_auth_tmp.txt
#RUN cat config/initializers/devise_token_fix_assets_precomiple.txt > config/initializers/devise_token_auth.rb
#RUN cat config/initializers/devise_token_auth_tmp.txt >> config/initializers/devise_token_auth.rb
RUN RAILS_ENV=production PRECOMPILE=true bundle exec rake assets:precompile

RUN chown -R app:app /home/app/webapp
EXPOSE 80
EXPOSE 443

CMD ["/sbin/my_init"]
