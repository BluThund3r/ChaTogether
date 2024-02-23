FROM gradle:8.6-jdk21

WORKDIR /backend

COPY . .

ENV PORT=8080

EXPOSE 8080

CMD ["./gradlew", "bootRun"]
