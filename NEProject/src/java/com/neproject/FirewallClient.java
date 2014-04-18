/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.neproject;

import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.net.Socket;
import java.net.UnknownHostException;

/**
 *
 * @author Bhargav
 */
public class FirewallClient {
    String server=null;
    Integer port=null;
    private Socket socket = null;
    private DataInputStream streamIn = null;
    private DataOutputStream streamOut = null;

    public FirewallClient(String server,Integer port) {
        this.server=server;
        this.port=port;
        
    }

    public String send(String blockRule) {
        String res=null;
       try
      {  
        socket = new Socket(server, port);
        streamIn  = new DataInputStream(socket.getInputStream());
        streamOut = new DataOutputStream(socket.getOutputStream());
         System.out.println("Connected: " + socket);
      }
      catch(UnknownHostException uhe)
      {  System.out.println("Host unknown: " + uhe.getMessage());
      }
      catch(IOException ioe)
      {  System.out.println("Unexpected exception: " + ioe.getMessage());
      }
        try
         {
            streamOut.writeBytes(blockRule);
            streamOut.flush();
         }
         catch(IOException ioe)
         {  System.out.println("Sending error: " + ioe.getMessage());
         }
        try{
            res=streamIn.readLine();
        }catch(Exception e){
            System.out.println("Sending error: " + e.getMessage());
        }
        return res;

    }
}
