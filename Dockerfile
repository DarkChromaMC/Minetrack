FROM node:16

ARG TINI_VER="v0.19.0"

# install tini
ADD https://github.com/krallin/tini/releases/download/$TINI_VER/tini /sbin/tini
RUN chmod +x /sbin/tini

# install sqlite3 and gosu (for user switching)
RUN apt-get update                                                   \
 && apt-get install --quiet --yes --no-install-recommends sqlite3 gosu \
 && apt-get clean      --quiet --yes                                 \
 && apt-get autoremove --quiet --yes                                 \
 && rm -rf /var/lib/apt/lists/*

# copy minetrack files
WORKDIR /usr/src/minetrack
COPY . .

# build minetrack
RUN npm install --build-from-source \
 && npm run build

# Copy the entrypoint script and make it executable
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

# Create user and group.
# The 'chown' is only for the application files now.
RUN addgroup --gid 10043 --system minetrack \
 && adduser  --uid 10042 --system --ingroup minetrack --no-create-home --gecos "" minetrack \
 && chown -R minetrack:minetrack /usr/src/minetrack

EXPOSE 8080

# Use the new script as the entrypoint. It will run as ROOT.
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# The entrypoint script will execute this command as the 'minetrack' user.
CMD ["/sbin/tini", "--", "node", "main.js"]
