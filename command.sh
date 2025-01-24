nats stream list

nats stream info wadm_commands

nats kv info

[jaykchen@nr200:~/projects/wasmCloud/examples/rust/components/dog-fetcher]$ nats kv info
? Select a Bucket  [Use arrows to move, type to filter]
> CONFIGDATA_default
LATTICEDATA_default
wadm_manifests
wadm_state

nats kv ls  LATTICEDATA_default
CLAIMS_MCSQTVHYUHS7HHGHLQ24HTDJOH5FXR23QBVWS7BIVZNT3GP2N3VL6Y6M
COMPONENT_dog_fetcher-http_component
CLAIMS_VAG3QITQQ2ODAOWB5TTQSDJ53XK3SHBEIFNK4AYJ5RKAX2UNSCAPHA5M
COMPONENT_dog_fetcher-httpserver
CLAIMS_VAJBKGSN2RA7XUFC2PY7M52AC7VV3OS3QRAQ26OVPRTZWOFILZEDIUPP
COMPONENT_dog_fetcher-httpclient

[jaykchen@nr200:~/projects/wasmCloud/examples/rust/components/dog-fetcher]$ nats kv ls  wadm_state
host_default
component_default
provider_default

# View stream subjects
nats stream subjects wadm_commands

# Subscribe to new commands
nats sub "wadm.cmd.*"

# View stream in real-time
nats stream view wadm_commands


# Configure root directory for blobstore
wash config put root-directory root=/tmp/blobstore

# Configure HTTP server with correct address and port
wash config put default-http address=0.0.0.0:8000

# Update HTTP server link with correct interface and config
wash link put http-server blobby-blobby wasi http --interface incoming-handler --source-config default-http

# Update blobstore link with all required interfaces
wash link put blobstore blobby-blobby wasi blobstore --interface blobstore,container,types --target-config root-directory

curl localhost:8000/wasmcloud.toml --data-binary @wasmcloud.toml

use std::io::Write as _;

use http::{
    header::{ALLOW, CONTENT_LENGTH},
    StatusCode,
};

use ::wasi::io::streams::InputStream;
use wasmcloud_component::http::Server;
use wasi::exports::http::incoming_handler::Guest;
use wasmcloud_component::wasi::http::types::*;
use wasmcloud_component::wasi::blobstore;
use wasmcloud_component::wasi::logging::logging::{log, Level};
use wasmcloud_component::wasi::blobstore::types;

wasmcloud_component::export!(Blobby);

[dependencies]
http = "1.1.0"
wasi = "0.13.2"
wasmcloud-component = { version = "0.2.1", path = "/home/jaykchen/projects/wasmCloud/crates/component", features = ["http"]}
wit-bindgen = "0.32"
wit-bindgen-wrpc = "0.9.0"


wash config put default-http address=0.0.0.0:8000
wash config put target_config url="redis://10.0.0.129:6379"
wash link put counter kvredis --interface atomics --interface store wasi keyvalue --target-config target_config

wash call fetcher \
  "wasi:http/incoming-handler.handle" \
  --http-method GET \
  --http-body "/" \
  --http-scheme http \
  --http-host localhost \
  --http-port 8000


{
  "status": 200,
  "headers": {},
  "body": "https://images.dog.ceo/breeds/cattledog-australian/IMG_2432.jpg"
}


wash call blobby-blobby "wasi:http/incoming-handler.handle" \
  --http-method DELETE \
  --http-scheme http \
  --http-host localhost:8000/myfile.txt \
  --http-body  "{}"


echo '{"body": "hello", "reply_to": null, "subject": "wasmcloud.echo"}' | wash call rust_echo_messaging-nats "wasmcloud:messaging/handler.handle-message"


cat > redis.conf << EOF
bind 0.0.0.0
protected-mode no
port 6379
EOF

podman run -d \
  --name redis_server \
  -v $PWD/redis.conf:/usr/local/etc/redis/redis.conf \
  -p 6379:6379 \
  redis redis-server /usr/local/etc/redis/redis.conf

podman rm -f redis_server

 redis-cli -h 10.0.0.129 -p 6379 ping

 wash call rust_http_kv-counter "wasi:http/incoming-handler.handle"

 wash call counter "wasi:http/incoming-handler.handle" \
  --http-method GET \
  --http-scheme http \
  --http-host "localhost/peter" \
  --http-port 8000 \
  --http-content-type "application/octet-stream"