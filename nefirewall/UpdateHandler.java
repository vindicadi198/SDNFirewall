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

	String network;
	short prefix_length;
	char protocol;
	short port;
	ArrayList<IOFSwitch> switches;
    char operator;
    protected IFloodlightProviderService floodlightProvider;
    Socket client;
    FloodlightContext cntx;
	public UpdateHandler(ArrayList<IOFSwitch> updated,
							IFloodlightProviderService flood,Socket cl,FloodlightContext cntx) {
		this.client = cl;
		String net;short prefix;char proto;short port;char oper;
		try{
			InputStream sockStream = client.getInputStream();
			BufferedReader br = new BufferedReader(new InputStreamReader(sockStream));
			String req = br.readLine();
			System.out.println("request is "+req);
			JSONParser parser = new JSONParser();
			Object jsonObj =parser.parse(req);
			JSONObject json = (JSONObject) jsonObj;
			net = (String)json.get("network");
			prefix = Short.parseShort((String)json.get("prefix_length"));
			proto = ((String)json.get("protocol")).charAt(0);
			port = Short.parseShort((String)json.get("port"));
			oper = ((String)json.get("operation")).charAt(0);
			System.out.println("Values are "+net+" "+prefix+" "+proto+" "+port+" "+oper);
			this.network = net;
			this.prefix_length = prefix;
			this.protocol = proto;
			this.port = port;
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
            	ret=writeBlockingRule(sw, network, prefix_length, protocol, port);
            }else if(this.operator=='D' || this.operator=='U'){
            	ret=deleteBlockingRule(sw,network,prefix_length,protocol,port);
            	if(this.operator=='U'){
            		ret=writeBlockingRule(sw, network, prefix_length, protocol, port);
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
			//BufferedWriter bw = new BufferedWriter(new OutputStreamWriter(os));
			os.writeBytes("Success");
	    	this.client.close();
	    }catch(IOException e){
	    	System.out.println("Client Socket close error "+e.getMessage());
	    }
	}
	public String writeBlockingRule(IOFSwitch sw,String network,short prefix,char proto,short port){
		OFMatch match = new OFMatch();
		match.setWildcards(Wildcards.EXACT.matchOn(Flag.TP_DST).matchOn(Flag.NW_SRC).withNwSrcMask(prefix).matchOn(Flag.NW_PROTO).matchOn(Flag.DL_TYPE));
		match.setDataLayerType(Ethernet.TYPE_IPv4);
		if(proto == 'T')
			match.setNetworkProtocol(IPv4.PROTOCOL_TCP);
		else
			match.setNetworkProtocol(IPv4.PROTOCOL_UDP);
		match.setNetworkSource(IPv4.toIPv4Address(network));
		match.setTransportDestination(port);
		OFFlowMod flowMod = (OFFlowMod) floodlightProvider.getOFMessageFactory().getMessage(OFType.FLOW_MOD);
        flowMod.setMatch(match);
        flowMod.setCookie(LearningSwitch.LEARNING_SWITCH_COOKIE);
        flowMod.setCommand(OFFlowMod.OFPFC_ADD);
        flowMod.setIdleTimeout((short)0);
        flowMod.setHardTimeout((short)0);
        flowMod.setPriority((short)100);
        flowMod.setBufferId(OFPacketOut.BUFFER_ID_NONE);
        flowMod.setFlags((short) (1 << 0));
        List<OFAction> actions = new ArrayList<OFAction>();
        flowMod.setActions(actions);
        try{
        	sw.write(flowMod, this.cntx);
        	sw.flush();
        }catch(Exception e){
        	System.out.println("Write flow rule failed UpdateHandler at"+Thread.currentThread().getStackTrace()[1].getLineNumber()+" with message "+e.getMessage());
        	return e.getMessage();
        }
        return null;
	}

	public String deleteBlockingRule(IOFSwitch sw,String network,short prefix,char proto,short port){
		OFMatch match = new OFMatch();
		match.setWildcards(Wildcards.EXACT.matchOn(Flag.TP_DST).matchOn(Flag.NW_SRC).withNwSrcMask(prefix).matchOn(Flag.NW_PROTO).matchOn(Flag.DL_TYPE));
		match.setDataLayerType(Ethernet.TYPE_IPv4);
		if(proto == 'T')
			match.setNetworkProtocol(IPv4.PROTOCOL_TCP);
		else
			match.setNetworkProtocol(IPv4.PROTOCOL_UDP);
		match.setNetworkSource(IPv4.toIPv4Address(network));
		match.setTransportDestination(port);
		OFFlowMod flowMod = (OFFlowMod) floodlightProvider.getOFMessageFactory().getMessage(OFType.FLOW_MOD);
        flowMod.setMatch(match);
        flowMod.setCookie(LearningSwitch.LEARNING_SWITCH_COOKIE);
        flowMod.setCommand(OFFlowMod.OFPFC_DELETE);
        flowMod.setIdleTimeout((short)0);
        flowMod.setHardTimeout((short)0);
        flowMod.setPriority((short)100);
        flowMod.setBufferId(OFPacketOut.BUFFER_ID_NONE);
        flowMod.setFlags((short) (1 << 0));
        List<OFAction> actions = new ArrayList<OFAction>();
        flowMod.setActions(actions);
        flowMod.setOutPort(OFPort.OFPP_NONE);
        try{
        	sw.write(flowMod, this.cntx);
        	sw.flush();
        }catch(Exception e){
        	System.out.println("Delete flow rule failed UpdateHandler at"+Thread.currentThread().getStackTrace()[1].getLineNumber()+" with message "+e.getMessage());
        	return e.getMessage();
        }
        return null;
	}
}
