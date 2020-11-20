<?php defined('BASEPATH') OR exit('No direct script access allowed');

require APPPATH . '/libraries/REST_Controller.php';
use Restserver\Libraries\REST_Controller;

class Chat extends REST_Controller {

    public function __construct() {
        parent::__construct();
        $this->load->model("Chat_model");
    }
    
    public function insert_post(){
        $senderName = $this->post("sender_name");
        $message = $this->post("message");
        $sendAt = $this->post("send_at");

        $data = [ 
            "sender_name" => $senderName,
            "message" => $message,
            "send_at" => $sendAt
        ];

        if($this->Chat_model->insertMessage($data)){
            $this->response([
                'status' => TRUE
            ], REST_Controller::HTTP_OK);
        }else {
            $this->response([
                'status' => FALSE
            ], REST_Controller::HTTP_OK);
        }
    }

    public function recent_get(){
        $data = $this->Chat_model->getRecentChat();
        $this->response([
            'status' => TRUE, 
            'data' => $data
        ], REST_Controller::HTTP_OK);
    }
}