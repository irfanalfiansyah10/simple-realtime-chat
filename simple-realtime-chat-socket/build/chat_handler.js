"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
var moment_1 = __importDefault(require("moment"));
var axios_1 = __importDefault(require("axios"));
/**
 * Class that handle chat event retrieved from App
 */
var ChatHandler = /** @class */ (function () {
    function ChatHandler(socket, server) {
        this.username = socket.handshake.headers['username'];
        this.server = server;
    }
    /**
     * User sends chat
     * @param json chat data, which contains
     * @var message (required) => Message
     */
    ChatHandler.prototype.onSendChat = function (json) {
        var _this = this;
        console.log(json);
        var data = JSON.parse(json);
        var params = {
            'sender_name': this.username,
            'message': data.message,
            'send_at': moment_1.default().valueOf().toString()
        };
        /* Insert message to database via REST API,
           if success send message to all users in app */
        this.post("chat/insert", params, function (r) {
            _this.emitChat(params);
        });
    };
    /**
     * Server sends chat to room
     */
    ChatHandler.prototype.emitChat = function (data) {
        this.server.to("app").emit(ChatHandler.SOMEONE_SEND_MESSAGE, data);
    };
    ChatHandler.prototype.post = function (path, params, callback) {
        axios_1.default.post("http://localhost:8888/simple-realtime-chat-rest/index.php/" + path, params)
            .then(function (response) {
            callback === null || callback === void 0 ? void 0 : callback(response.data);
        })
            .catch(function (error) {
            console.log("POST Request to = " + path + " with parameter " + JSON.stringify(params) + " failed with result " + error);
        });
    };
    ChatHandler.CONNECTED = 'connection';
    ChatHandler.SENDING_MESSAGE = 'i\'m sending message';
    ChatHandler.SOMEONE_SEND_MESSAGE = 'someone send message';
    return ChatHandler;
}());
exports.default = ChatHandler;
