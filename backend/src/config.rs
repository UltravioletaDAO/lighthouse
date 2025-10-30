// Configuration loading from environment variables

use anyhow::Result;
use serde::Deserialize;

#[derive(Debug, Clone, Deserialize)]
pub struct Config {
    pub environment: String,
    pub host: String,
    pub port: u16,

    pub mongodb_uri: String,
    pub mongodb_database: String,
    pub redis_url: String,

    pub avax_rpc_url: String,
    pub avax_chain_id: u64,

    pub lighthouse_address: String,
    // Private key loaded separately from AWS Secrets Manager or .env
}

impl Config {
    pub fn from_env() -> Result<Self> {
        dotenvy::dotenv().ok();

        Ok(Config {
            environment: std::env::var("ENVIRONMENT").unwrap_or_else(|_| "development".to_string()),
            host: std::env::var("HOST").unwrap_or_else(|_| "0.0.0.0".to_string()),
            port: std::env::var("PORT")
                .unwrap_or_else(|_| "8080".to_string())
                .parse()?,

            mongodb_uri: std::env::var("MONGODB_URI")
                .unwrap_or_else(|_| "mongodb://localhost:27017/lighthouse".to_string()),
            mongodb_database: std::env::var("MONGODB_DATABASE")
                .unwrap_or_else(|_| "lighthouse".to_string()),
            redis_url: std::env::var("REDIS_URL")
                .unwrap_or_else(|_| "redis://localhost:6379".to_string()),

            avax_rpc_url: std::env::var("AVAX_RPC_URL")
                .unwrap_or_else(|_| "https://api.avax-test.network/ext/bc/C/rpc".to_string()),
            avax_chain_id: std::env::var("AVAX_CHAIN_ID")
                .unwrap_or_else(|_| "43113".to_string())
                .parse()?,

            lighthouse_address: std::env::var("LIGHTHOUSE_ADDRESS")?,
        })
    }
}
