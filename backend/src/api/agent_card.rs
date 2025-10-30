// A2A protocol agent card - TODO

use axum::Json;
use serde_json::{json, Value};

pub async fn get_agent_card() -> Json<Value> {
    Json(json!({
        "schema_version": "1.0.0",
        "agent_id": "lighthouse",
        "name": "Lighthouse Monitoring Platform",
        "description": "Universal trustless monitoring for Web3",
        "domains": [
            "lighthouse.ultravioletadao.xyz",
            "faro.ultravioletadao.xyz"
        ],
        "skills": [],
        "payment_methods": []
    }))
}
