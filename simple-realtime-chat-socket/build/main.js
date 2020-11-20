"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
var express_1 = __importDefault(require("express"));
var socket_io_1 = __importDefault(require("socket.io"));
var http_1 = __importDefault(require("http"));
var chat_handler_1 = __importDefault(require("./chat_handler"));
var app = express_1.default();
var http = http_1.default.createServer(app);
var io = socket_io_1.default(http);
/**
 * Middleware Server
 *
 * throw Authentication Error when no headers with
 * x-lets-connect-id-user found
 */
io.use(function (socket, next) {
    var username = socket.handshake.headers['username'];
    if (username != null) {
        return next();
    }
    return next(new Error('Authentication Error'));
});
/**
 * Automatically called when user connected to socket
 */
io.on(chat_handler_1.default.CONNECTED, function (socket) {
    var handler = new chat_handler_1.default(socket, io);
    socket.on(chat_handler_1.default.SENDING_MESSAGE, function (data) { return handler.onSendChat(data); });
    socket.join("app");
});
app.get('/austin', function (req, res) {
    res.sendFile('/Users/apple/Documents/Glovory Project/CSP/simple-realtime-chat-socket/page/austin.html');
});
app.get('/bryan', function (req, res) {
    res.sendFile('/Users/apple/Documents/Glovory Project/CSP/simple-realtime-chat-socket/page/bryan.html');
});
app.get('/louis', function (req, res) {
    res.sendFile('/Users/apple/Documents/Glovory Project/CSP/simple-realtime-chat-socket/page/louis.html');
});
/**
* Register socket to port :3000
*/
http.listen(3000, function () { return console.log("Connection Established"); });
