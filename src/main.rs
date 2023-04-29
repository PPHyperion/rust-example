use actix_web::{get, App, HttpRequest, HttpServer, Result};

#[get("/{name}")]
async fn hello(req: HttpRequest) -> Result<String> {
    let name = req.match_info().get("name").unwrap_or("World");
    Ok(format!("Hello {}!", &name))
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    HttpServer::new(|| App::new().service(hello))
        .bind(("127.0.0.1", 8080))?
        .run()
        .await
}
