# Dokku Vendor Server

A simple sinatra app that acts like `BUILDPACK_VENDOR_URL` and downloads requested file to local and serves the file for dokku deploys. Like ruby binaries, bundler etc.

Blog post: https://medium.com/@mbrain0/how-to-speed-up-dokku-deployments-cc2f42015e55

# Why?
I'm deploying Rails apps to dokku-powered DO servers located in AMS1 and SGP1, it takes more than 5 or 6 minutes each deploy because its downloading Ruby binaries each time, even worse connection times out sometimes. Its faster if you serve them from the same server.

# Installation

*only tested for heroku-buildpack-ruby*

* Deploy this app to your dokku server.

```bash
#server
dokku apps:create dokku-vendor
```

```
#local
git clone git@github.com:beydogan/dokku-vendor.git
cd dokku-vendor
git remote add dokku dokku@SERVER-IP:dokku-vendor
git push dokku master
```

* Create a persistent storage binded to `/tmp/dokku-vendor`


```bash
#server
sudo mkdir /dokku-vendor
sudo chown dokku /dokku-vendor
dokku storage:mount dokku-vendor /dokku-vendor:/tmp/dokku-vendor
```

* Use your app url as `BUILDPACK_VENDOR_URL` to your other apps.

```bash
#server
dokku config:set my-rails-app --no-restart BUILDPACK_VENDOR_URL=SERVER-IP:PORT/heroku-buildpack-ruby/
```


# Restricting external access(optional)

You can restrict access from outside of the server by following below. We need to create a nginx config for dokku-vendor app to restrict all IPs except docker subnet(`172.17.0.0/16`) 

```bash
#server
mkdir /home/dokku/dokku-vendor/nginx.conf.d/
echo 'allow 172.17.0.0/16; deny all;' > /home/dokku/dokku-vendor/nginx.conf.d/ip_access.conf
chown dokku:dokku /home/dokku/dokku-vendor/nginx.conf.d/ip_access.conf
service nginx reload
```

* **All done!** You can just push your app as usual.
