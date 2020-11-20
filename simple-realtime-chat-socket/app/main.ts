import express from 'express'
import socket, { Socket } from 'socket.io'
import _http from 'http'
import ChatHandler from './chat_handler';

let app = express();
let http = _http.createServer(app);
let io = socket(http);

/**
 * Middleware Server
 * 
 * throw Authentication Error when no headers with
 * x-lets-connect-id-user found
 */
io.use((socket, next) => {
    let username = socket.handshake.headers['username'];
    
    if(username != null){
        return next();
    }

    return next(new Error('Authentication Error'));
});

/**
 * Automatically called when user connected to socket
 */
io.on(ChatHandler.CONNECTED, function(socket: Socket) {
    let handler = new ChatHandler(socket, io)

    socket.on(ChatHandler.SENDING_MESSAGE, (data) => handler.onSendChat(data))

    socket.join("app")
});

/**
* Register socket to port :3000
*/
http.listen(3000, () => console.log("Connection Established"));