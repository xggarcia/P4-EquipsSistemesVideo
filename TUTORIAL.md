# Step 1 - Running the Backend Service

First we go back to the first version of the project:

```bash
git checkout 1.0.0
```

![alt text](image.png)
This switches to the v1.0.0 tag so we only have the basic backend code.

Then we start the backend server using Docker:

```bash
docker-compose run --rm --service-ports backend
```

![alt text](image-1.png)
This builds and runs the backend container, which is an Nginx server with Lua that listens on port 8080.

Finally we test it by making a request:

```bash
curl http://localhost:8080/path/to/my/content.ext
```

![alt text](image-2.png)
This sends a GET request to the backend and we should get back a JSON response like `{"service": "api", "value": 42}`.

---

# Step 2 - Adding Cache Headers

We checkout the next version:

```bash
git checkout 1.0.1
```

![alt text](image-3.png)
This updates the backend to include a `Cache-Control` header in the response.

We start the backend again:

```bash
docker-compose run --rm --service-ports backend
```

![alt text](image-4.png)
Then we test it with a custom cache duration:

```bash
curl -i "http://localhost:8080/path/to/my/content.ext?max_age=30"
```

![alt text](image-5.png)

This shows us the response headers, and we should see `Cache-Control: public, max-age=30` which tells caches they can store this content for 30 seconds.

---

# Step 3 - Adding Metrics

We checkout the metrics version:

```bash
git checkout 1.1.0
```

![alt text](image-6.png)
This adds the VTS module to Nginx so we can see traffic stats.

We start the backend:

```bash
docker-compose run --rm --service-ports backend
```

Then we open the metrics page in the browse:

```
http://localhost:8080/status/format/html
```

![alt text](image-7.png)

This shows us a dashboard with request counts, status codes, and response times right inside Nginx.

---

# Step 4 - Adding the CDN Edge (Proxy)

We checkout the proxy version:

```bash
git checkout 2.0.0
```

This adds a second Nginx node (the "edge") that sits in front of the backend.

We start all the services:

```bash
docker-compose up
```

![alt text](image-8.png)

Then we test accessing through the edge instead of the backend:

```bash
curl http://localhost:8081/path/to/my/content.ext
```

![alt text](image-9.png)

This goes through the edge on port 8081, which forwards the request to the backend on port 8080 using `proxy_pass`.

---

# Step 5 - Enabling Caching on the Edge

We checkout the caching version:

```bash
git checkout 2.1.0
```

This adds `proxy_cache` to the edge so it stores responses locally.

We start the services:

```bash
docker-compose up
```

![alt text](image-10.png)

We make the first request (this will be a cache MISS):

```bash
curl.exe -i http://localhost:8081/path/to/my/content.ext
```

![alt text](image-11.png)

Then we make the same request again (this should be a cache HIT):

```bash
curl.exe -i http://localhost:8081/path/to/my/content.ext
```

![alt text](image-12.png)

The second time we should see `X-Cache-Status: HIT` in the headers, meaning the edge served it from cache without hitting the backend.

---

# Step 6 - Monitoring with Prometheus and Grafana

We checkout the monitoring version:

```bash
git checkout 2.2.0
```

This adds Prometheus and Grafana containers to scrape and visualize metrics.

We start everything:

```bash
docker-compose up
```

We run the load test to generate traffic:

```bash
wrk -c10 -t2 -d600s -s ./src/load_tests.lua --latency http://localhost:8081
```

This runs a 10-minute benchmark with 10 connections and 2 threads against the edge.

Then we open Grafana to see the results:

```
http://localhost:9091
```

![alt text](image-10.png)
We log in with username `admin` and password `admin`, add Prometheus as a data source with URL `http://prometheus:9090`, and create a dashboard to see cache hit rates and latency.

---

# Step 7 - Fine Tuning (Cache Lock and Timeouts)

We checkout the fine tuning version:

```bash
git checkout 3.0.0
```

![alt text](image-11.png)

This adds `proxy_cache_lock`, timeouts, and `proxy_cache_use_stale` to the edge config.

We start the services:

```bash
docker-compose up
```

![alt text](image-13.png)

We run the load test:

```bash
./load_test.sh
```

![alt text](image-12.png)

This tests the CDN with cache lock enabled, which collapses multiple requests for the same uncached content into a single backend request, reducing thundering herd problems.

We check Grafana at `http://localhost:9091` to see that timeout errors decreased and less traffic reached the backend.

## ![alt text](image-14.png)

# Step 8 - Load Balancing with Round Robin

We checkout the load balancer version:

```bash
git checkout 4.0.0
```

This adds a load balancer in front of 3 edge nodes using the default round-robin policy.

We start everything:

```bash
docker-compose up
```

We run the load test:

```bash
./load_test.sh
```

![alt text](image-15.png)

This distributes requests equally across all 3 edges, but since it's not cache-aware, the same content might be cached on multiple edges which wastes memory.

---

# Step 9 - Load Balancing with Consistent Hashing

We checkout the consistent hashing version:

```bash
git checkout 4.0.1
```

This changes the load balancer to use `hash $request_uri consistent` so the same URL always goes to the same edge.

We start the services:

```bash
docker-compose up
```

We run the load test:

```bash
./load_test.sh
```

![alt text](image-16.png)

This gives a better cache hit ratio because each URL is always routed to the same edge node, but if one piece of content goes viral, that single edge gets all the traffic.
