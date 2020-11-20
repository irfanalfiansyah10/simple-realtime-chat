<?php defined('BASEPATH') OR exit('No direct script access allowed');

class Chat_model extends CI_Model {
    public function insertMessage($data){
        $this->db->insert('messages', $data);
        
        return $this->db->insert_id();
    }

    public function getRecentChat(){
        $this->db->select('id, sender_name, message, send_at');
        $this->db->from('messages');

        return $this->db->get()->result_array();
    }
}