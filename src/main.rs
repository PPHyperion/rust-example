use actix_web::{web, App, HttpRequest, HttpServer, Result};

async fn hello(req: HttpRequest) -> Result<String> {
    let name = req.match_info().get("name").unwrap_or("World");
    Ok(format!("Hello {}!", &name))
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    HttpServer::new(|| {
        App::new()
            .route("/", web::get().to(hello))
            .route("/{name}", web::get().to(hello))
    })
    .bind(("127.0.0.1", 8080))?
    .run()
    .await
}
