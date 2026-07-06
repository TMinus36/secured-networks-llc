# Multi-stage build for minimal surface area and stateless execution
FROM docker.io/library/rust:1.79-slim-bookworm AS builder
WORKDIR /usr/src/att-telemetry
COPY . .
# Enforce static linking for isolated FCOS execution
RUN cargo build --release

FROM gcr.io/distroless/cc-debian12 AS runtime
WORKDIR /app
COPY --from=builder /usr/src/att-telemetry/target/release/att-telemetry /app/
USER nonroot:nonroot
EXPOSE 8080
CMD ["./att-telemetry"]
