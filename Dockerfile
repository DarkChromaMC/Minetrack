FROM node:16

ARG TINI_VER="v0.19.0"

# install tini
ADD https://github.com/krallin/tini/releases/download/$TINI_VER/tini /sbin/tini
RUN chmod +x /sbin/tini

# install sqlite3
RUN apt-get update                                                   \
 && apt-get install    --quiet --yes --no-install-recommends sqlite3 \
 && apt-get clean      --quiet --yes                                 \
 && apt-get autoremove --quiet --yes                                 \
 && rm -rf /var/lib/apt/lists/*

# copy minetrack files
WORKDIR /usr/src/minetrack
COPY . .

# build minetrack
RUN npm install --build-from-source \
 && npm run build

# Copy the new entrypoint script and make it executable
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

# run as non root
# Create user, create /data dir for volume, and set up symlink
RUN addgroup --gid 10043 --system minetrack \
 && adduser  --uid 10042 --system --ingroup minetrack --no-create-home --gecos "" minetrack \
 && mkdir -p /data \
 && ln -s /data/database.sql /usr/src/minetrack/database.sql \
 && chown -R minetrack:minetrack /usr/src/minetrack

USER minetrack

EXPOSE 8080

# Use the new script as the entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# The script will execute this command after setting permissions
CMD ["/sbin/tini", "--", "node", "main.js"]
