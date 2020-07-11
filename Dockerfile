FROM daemoohn/build-ogv.js:0.1
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
# check it on https://www.fromlatest.io/#/
