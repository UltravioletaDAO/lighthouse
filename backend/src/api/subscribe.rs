// Subscription endpoints - TODO

use axum::Json;
use serde_json::{json, Value};

pub async fn create_subscription() -> Json<Value> {
    Json(json!({"message": "TODO: Implement subscription creation"}))
}

pub async fn get_subscription() -> Json<Value> {
    Json(json!({"message": "TODO: Implement get subscription"}))
}

pub async fn update_subscription() -> Json<Value> {
    Json(json!({"message": "TODO: Implement update subscription"}))
}

pub async fn unsubscribe() -> Json<Value> {
    Json(json!({"message": "TODO: Implement unsubscribe"}))
}
