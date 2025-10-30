// Metrics endpoints - TODO

use axum::Json;
use serde_json::{json, Value};

pub async fn get_metrics() -> Json<Value> {
    Json(json!({"message": "TODO: Implement metrics"}))
}

pub async fn prometheus_metrics() -> String {
    "# TODO: Prometheus metrics\n".to_string()
}
