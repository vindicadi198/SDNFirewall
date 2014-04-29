package net.floodlightcontroller.nefirewall;

import java.util.ArrayList;
import java.util.List;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.DataOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.net.*;

import org.openflow.protocol.OFFlowMod;
import org.openflow.protocol.OFMatch;
import org.openflow.protocol.OFMessage;
import org.openflow.protocol.OFPacketOut;
import org.openflow.protocol.OFPort;
import org.openflow.protocol.OFType;
import org.openflow.protocol.Wildcards;
import org.openflow.protocol.Wildcards.Flag;
import org.openflow.protocol.action.OFAction;

import net.floodlightcontroller.core.FloodlightContext;
import net.floodlightcontroller.core.IFloodlightProviderService;
import net.floodlightcontroller.core.IOFSwitch;
import net.floodlightcontroller.learningswitch.LearningSwitch;
import net.floodlightcontroller.packet.Ethernet;
import net.floodlightcontroller.packet.IPv4;

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;

public class UpdateHandler extends Thread {

	Rule rule;
	ArrayList<IOFSwitch> switches;
    char operator;
    protected IFloodlightProviderService floodlightProvider;
    Socket client;
    FloodlightContext cntx;
	public UpdateHandler(ArrayList<IOFSwitch> updated,
							IFloodlightProviderService flood,Socket cl,FloodlightContext cntx) {
		this.client = cl;
		String src_net,dst_net;short src_prefix,dst_prefix;char proto;short port,priority;char oper;
		try{
			InputStream sockStream = client.getInputStream();
			BufferedReader br = new BufferedReader(new InputStreamReader(sockStream));
			String req = br.readLine();
			System.out.println("request is "+req);
			
			JSONParser parser = new JSONParser();
			Object jsonObj =parser.parse(req);
			JSONObject json = (JSONObject) jsonObj;
			
			src_net = (String)json.get("src_network");
			src_prefix = Short.parseShort((String)json.get("src_prefix_length"));
			dst_net = (String)json.get("dst_network");
			dst_prefix = Short.parseShort((String)json.get("dst_prefix_length"));
			proto = ((String)json.get("protocol")).charAt(0);
			port = Short.parseShort((String)json.get("port"));
			priority = Short.parseShort((String)json.get("priority"));
			oper = ((String)json.get("operation")).charAt(0);
			this.rule = new Rule(src_net, src_prefix, dst_net, dst_prefix, proto, port, priority);
			this.switches = (ArrayList<IOFSwitch>)updated.clone();
	        this.operator = oper;
	        this.floodlightProvider = flood;
	        this.cntx=cntx;
			this.start();
			
		}catch(IOException e){
			System.out.println("Getting input stream failed in UpdateHandler "+e.getMessage());
		}
		catch(ParseException p){
			System.out.println("JSON parsing exception "+p.getMessage());
		}
		
	}
	@Override
	public void run(){
		System.out.println("Starting thread");
		String ret="";
	    for(IOFSwitch sw : this.switches){
	    	System.out.println("Adding request for switch "+sw.getId());
            if(this.operator=='I'){
            	ret=Firewall.writeBlockingRule(sw,this.rule,this.cntx,this.floodlightProvider);
            }else if(this.operator=='D' || this.operator=='U'){
            	ret=Firewall.deleteBlockingRule(sw,this.rule,this.cntx,this.floodlightProvider);
            	if(this.operator=='U'){
            		ret=Firewall.writeBlockingRule(sw,this.rule,this.cntx,this.floodlightProvider);
            	}
            }
            if(ret!=null){
    	    	try{
    	    		DataOutputStream os =new DataOutputStream(this.client.getOutputStream());
    	    		os.writeBytes(ret+"on switch "+sw.getId()+"\n");
    	    	}catch(IOException e){
    	    		System.out.println("IOException at UpdateHandler "+e.getMessage());
    	    	}
    	    }
        }
	    System.out.println("Sending success");
	    try{
	    	DataOutputStream os =new DataOutputStream(this.client.getOutputStream());
			os.writeBytes("Success");
	    	this.client.close();
	    }catch(IOException e){
	    	System.out.println("Client Socket close error "+e.getMessage());
	    }
	}

	
}
