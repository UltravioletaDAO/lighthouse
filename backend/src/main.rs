// Lighthouse - Universal Trustless Monitoring Platform
// Copyright (c) 2025 Ultravioleta DAO

use axum::{
    routing::{get, post},
    Router,
};
use std::net::SocketAddr;
use tower_http::{
    cors::CorsLayer,
    trace::TraceLayer,
};
use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt};

mod config;
mod api;
mod monitors;
mod scheduler;
mod database;

use config::Config;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    // Initialize tracing/logging
    tracing_subscriber::registry()
        .with(
            tracing_subscriber::EnvFilter::try_from_default_env()
                .unwrap_or_else(|_| "lighthouse=debug,tower_http=debug".into()),
        )
        .with(tracing_subscriber::fmt::layer().json())
        .init();

    // Load configuration
    let config = Config::from_env()?;
    tracing::info!("Lighthouse starting up...");
    tracing::info!("Environment: {}", config.environment);

    // Initialize database connections
    let db = database::Database::new(&config).await?;
    tracing::info!("Database connected");

    // Initialize scheduler for background checks
    let scheduler = scheduler::Scheduler::new(db.clone());
    scheduler.start().await?;
    tracing::info!("Scheduler started");

    // Build API routes
    let app = Router::new()
        // Health check
        .route("/health", get(api::health::health_check))

        // Subscription management
        .route("/subscribe", post(api::subscribe::create_subscription))
        .route("/subscriptions/:id", get(api::subscribe::get_subscription))
        .route("/subscriptions/:id", post(api::subscribe::update_subscription))
        .route("/subscriptions/:id/unsubscribe", post(api::subscribe::unsubscribe))

        // Metrics & Status
        .route("/metrics/:id", get(api::metrics::get_metrics))
        .route("/metrics/prometheus", get(api::metrics::prometheus_metrics))

        // Agent Card (A2A protocol)
        .route("/.well-known/agent-card", get(api::agent_card::get_agent_card))

        // CORS
        .layer(CorsLayer::permissive())

        // Tracing
        .layer(TraceLayer::new_for_http())

        // Shared state
        .with_state(db);

    // Start server
    let addr = SocketAddr::from(([0, 0, 0, 0], config.port));
    tracing::info!("Lighthouse listening on {}", addr);

    axum::Server::bind(&addr)
        .serve(app.into_make_service())
        .await?;

    Ok(())
}
