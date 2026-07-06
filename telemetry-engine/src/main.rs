use axum::{routing::get, Router};
use std::net::SocketAddr;

#[tokio::main]
async fn main() {
    // Enforcing stateless execution; persistent state is strictly delegated to LXC 103 PostgreSQL
    let app = Router::new()
        .route("/health", get(|| async { "ATT Telemetry Engine: Operating in FCOS Compute Plane (VM 300)" }));

    let addr = SocketAddr::from(([0, 0, 0, 0], 8080));
    let listener = tokio::net::TcpListener::bind(addr).await.unwrap();
    axum::serve(listener, app).await.unwrap();
}
