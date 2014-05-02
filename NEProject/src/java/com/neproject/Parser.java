/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package com.neproject;
import java.io.*;
import java.sql.*;
import java.sql.DriverManager;
import java.util.HashMap;
import java.util.StringTokenizer;
/**
 *
 * @author adityakamath
 */
class Network{
    public String network;
    public short prefix;
    Network(String network,short prefix){
        this.network = network;
        this.prefix = prefix;
    }
    @Override
    public String toString(){
        return network+" "+prefix;
    }
}
public class Parser {
    public static boolean parse(String path,String server,String db_user,String passwd) {
        // TODO code application logic here
        File rules = null;
        HashMap<String,Network> networks = new HashMap<String,Network>();
        networks.put("$HOME_NET", new Network("172.16.0.0",(short)16));
        networks.put("$HTTP_SERVERS", new Network("172.16.0.0",(short)16));
        networks.put("$SQL_SERVERS", new Network("172.16.0.0",(short)16));
        networks.put("$EXTERNAL_NET", new Network("",(short)0));
        networks.put("any", new Network("",(short)0));
        HashMap<String,Short> ports = new HashMap<String,Short>();
        ports.put("$HTTP_PORTS",(short)80);
        ports.put("$ORACLE_PORTS",(short)1521);
        ports.put("$SSH_PORTS",(short)22);
        ports.put("any",(short)0);
        int i =1;
        
        try{
            Class.forName("org.postgresql.Driver");
            Connection db_con = DriverManager.getConnection("jdbc:postgresql://"+server+":5432/openflow",db_user,passwd);
            PreparedStatement del = db_con.prepareStatement("delete from suricata");
            del.executeUpdate();
            PreparedStatement ps = db_con.prepareStatement("INSERT INTO suricata values (?,?,?,?,?,?,?)");
            
            rules = new File(path);
            FileReader fr = new FileReader(rules);
            BufferedReader br = new BufferedReader(fr);
            while(br.ready()){
                String line = br.readLine();
                if(line.charAt(0)=='#'){
                    i++;
                    continue;
                }
                    
                String[] parsed = line.split(" ");
                String[] parsed1 = line.split("sid:");
                String sid = parsed1[1];
                //sid=st2.nextToken();
                sid = sid.split(";")[0];
                String protocol = parsed[1];
                char proto = ' ';
                if(protocol.equals("tcp"))
                    proto = 'T';
                else if(protocol.equals("udp"))
                    proto = 'U';
                else 
                    proto ='K';
                String source_net = parsed[2];
                if(networks.get(parsed[2])!=null)
                    source_net = networks.get(parsed[2]).network;
                String source_port = parsed[3];
                String dest_net = parsed[5];
                if(networks.get(parsed[5])!=null)
                    dest_net = networks.get(parsed[5]).network;
                String dest_port = parsed[6];
                if(ports.containsKey(parsed[6]))
                    dest_port = ports.get(parsed[6]).toString();
                if((networks.get(parsed[2])==null) 
                        || (networks.get(parsed[5])==null) 
                        || (!ports.containsKey(parsed[6]) && isNumeric(dest_port)==false)|| proto =='K'){
                    System.out.println(i+" "+protocol+" "+source_net+" "+source_port+" "+dest_net+" "+dest_port+" "+sid);
                    i++;
                    continue;
                }
                
                ps.setString(1, source_net);
                ps.setInt(2, networks.get(parsed[2]).prefix);
                ps.setString(3, dest_net);
                ps.setInt(4,networks.get(parsed[5]).prefix);
                ps.setString(5, Character.toString(proto));
                ps.setInt(6,Integer.parseInt(dest_port));
                ps.setInt(7, Integer.parseInt(sid));
                ps.executeUpdate();
                
                //System.out.println(i+" "+protocol+" "+source_net+" "+source_port+" "+dest_net+" "+dest_port+" "+sid);
                i++;
            }
        }catch(Exception e){
            System.out.println("Exception occured "+e.getMessage());
            e.printStackTrace();
            return false;
        }
        return true;
        
    }
    public static boolean isNumeric(String str)  
    {  
      try  
      {  
        int d = Integer.parseInt(str);  
      }  
      catch(NumberFormatException nfe)  
      {  
        return false;  
      }  
      return true;  
    }
}
