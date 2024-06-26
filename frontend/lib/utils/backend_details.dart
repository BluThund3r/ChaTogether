const _local = false;
const localHostName = "10.0.2.2";
const remoteHostName = "grossly-star-bear.ngrok-free.app";
const hostname = _local ? localHostName : remoteHostName;
const protocol = _local ? "http://" : "https://";
const port = _local ? ":8080" : "";
const wsProtocol = _local ? "ws://" : "wss://";
const baseUrl = protocol + hostname + port;
const baseWsUrl = wsProtocol + hostname + port;
const messagesFetchedOnce = 50;
