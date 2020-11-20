import { Socket, Server } from 'socket.io'
import moment from 'moment'
import axios, { AxiosResponse } from 'axios'

/**
 * Class that handle chat event retrieved from App
 */
export default class ChatHandler{
    public static readonly CONNECTED = 'connection'
    public static readonly SENDING_MESSAGE = 'i\'m sending message'
    public static readonly SOMEONE_SEND_MESSAGE = 'someone send message'

    private username: string
    private server: Server

    constructor(socket: Socket, server: Server){
        this.username = socket.handshake.headers['username']
        this.server = server
    }

    /**
     * User sends chat
     * @param json chat data, which contains
     * @var message (required) => Message
     */
    onSendChat(json: string): void {  
        console.log(json); 
        var data = JSON.parse(json)
        let params = {
            'sender_name' : this.username,
            'message' : data.message,
            'send_at' : moment().valueOf().toString()
        };
    
        /* Insert message to database via REST API, 
           if success send message to all users in app */
            
        this.post("chat/insert", params, (r) => {
            this.emitChat(params);
        });
    }

    /**
     * Server sends chat to room
     */
    emitChat(data: {[key: string]: any}): void{
        this.server.to("app").emit(ChatHandler.SOMEONE_SEND_MESSAGE, data)
    }

    private post(path: string, params?: {}, callback?: (response: string) => void) : void {
        axios.post<string>(`http://localhost:8888/simple-realtime-chat-rest/index.php/${path}`, params)
        .then((response: AxiosResponse<string>) => {
            callback?.(response.data);
        })
        .catch((error) => {
            console.log(`POST Request to = ${path} with parameter ${JSON.stringify(params)} failed with result ${error}`);
        });
    }
}