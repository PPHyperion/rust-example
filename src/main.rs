use std::net::TcpListener;

use env_logger::Env;
use sqlx::PgPool;
use zero2prod::{configuration, startup};

#[actix_web::main]
async fn main() -> Result<(), std::io::Error> {
    env_logger::Builder::from_env(Env::default().default_filter_or("info")).init();

    let configuration = configuration::get().expect("Failed to read configuration");
    let address = format!("127.0.0.1:{}", configuration.application_port);
    let listener = TcpListener::bind(address)?;

    let connection_pool = PgPool::connect(&configuration.database.connection_string())
        .await
        .expect("Failed to connect to Postgres.");

    startup::run(listener, connection_pool)?.await
}
