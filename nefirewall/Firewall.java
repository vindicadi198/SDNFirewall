package net.floodlightcontroller.nefirewall;

import java.util.Collection;
import java.util.List;
import java.util.Map;

import org.openflow.protocol.OFFlowMod;
import org.openflow.protocol.OFMatch;
import org.openflow.protocol.OFMessage;
import org.openflow.protocol.OFPacketOut;
import org.openflow.protocol.OFType;
import org.openflow.protocol.Wildcards;
import org.openflow.protocol.Wildcards.Flag;
import org.openflow.protocol.action.OFAction;

import net.floodlightcontroller.core.FloodlightContext;
import net.floodlightcontroller.core.IOFMessageListener;
import net.floodlightcontroller.core.IOFSwitch;
import net.floodlightcontroller.core.module.FloodlightModuleContext;
import net.floodlightcontroller.core.module.FloodlightModuleException;
import net.floodlightcontroller.core.module.IFloodlightModule;
import net.floodlightcontroller.core.module.IFloodlightService;
import net.floodlightcontroller.core.IFloodlightProviderService;

import java.util.ArrayList;
import java.util.concurrent.ConcurrentSkipListSet;
import java.util.Set;

import net.floodlightcontroller.learningswitch.LearningSwitch;
import net.floodlightcontroller.packet.Ethernet;
import net.floodlightcontroller.packet.IPv4;
import net.floodlightcontroller.packet.TCP;

import org.openflow.util.HexString;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;
import java.net.SocketAddress;
import java.sql.*;

public class Firewall implements IOFMessageListener, IFloodlightModule {
	
	protected IFloodlightProviderService floodlightProvider;
	Connection db_con = null;
	ArrayList<IOFSwitch> updated;
	Thread socketThread;
	FloodlightContext cntx=null;
	@Override
	public String getName() {
		// TODO Auto-generated method stub
		return this.getClass().getSimpleName();
	}

	@Override
	public boolean isCallbackOrderingPrereq(OFType type, String name) {
		// TODO Auto-generated method stub
		return false;
	}

	@Override
	public boolean isCallbackOrderingPostreq(OFType type, String name) {
		// TODO Auto-generated method stub
		return false;
	}

	@Override
	public Collection<Class<? extends IFloodlightService>> getModuleServices() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Map<Class<? extends IFloodlightService>, IFloodlightService> getServiceImpls() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Collection<Class<? extends IFloodlightService>> getModuleDependencies() {
		// TODO Auto-generated method stub
		Collection<Class<? extends IFloodlightService>> l =
		        new ArrayList<Class<? extends IFloodlightService>>();
		    l.add(IFloodlightProviderService.class);
		return l;
	}

	@Override
	public void init(FloodlightModuleContext context)
			throws FloodlightModuleException {
		// TODO Auto-generated method stub
		floodlightProvider =
                context.getServiceImpl(IFloodlightProviderService.class);
		updated = new ArrayList<IOFSwitch>();
		try{
			Class.forName("org.postgresql.Driver");
			db_con = DriverManager.getConnection("jdbc:postgresql://127.0.0.1:5432/openflow","postgres","iithiith");
		}catch(Exception e){
			System.out.println(e.getMessage());
		}
		socketThread = new Thread(new Runnable() {
			
			@Override
			public void run() {
				try{
					ServerSocket tcpSocket = new ServerSocket(12345);
					while(true){
						Socket client = tcpSocket.accept();
						System.out.println("New connection from "+client);
						new UpdateHandler(updated,floodlightProvider,client,cntx);
					}
				}catch(IOException e){
					System.out.println("Unable to create Server Socket");
				}
				
			}
		});
		socketThread.start();

	}

	@Override
	public void startUp(FloodlightModuleContext context)
			throws FloodlightModuleException {
		// TODO Auto-generated method stub
		floodlightProvider.addOFMessageListener(OFType.PACKET_IN, this);
        floodlightProvider.addOFMessageListener(OFType.FLOW_REMOVED, this);
        floodlightProvider.addOFMessageListener(OFType.ERROR, this);

	}

	@Override
	public net.floodlightcontroller.core.IListener.Command receive(
			IOFSwitch sw, OFMessage msg, FloodlightContext cntx) {
		// TODO Auto-generated method stub
		this.cntx=cntx;
		if(msg.getType() == OFType.PACKET_IN){
			System.out.println("received packet in");
			if(!updated.contains(sw)){
				updated.add(sw);
				try{
					PreparedStatement ps = db_con.prepareStatement("SELECT * FROM blocked");
					ResultSet rs = ps.executeQuery();
					while(rs.next()){
						String network = rs.getString("network");
						short prefix_length = rs.getShort("prefix_length");
						char protocol = rs.getString("protocol").charAt(0);
						short port = rs.getShort("port");
						writeBlockingRule(sw,msg,network,prefix_length,protocol,port,cntx);
						System.out.println("writing rule"+network+" port "+port);
					}
				}catch(SQLException e){
					System.out.println("Prepared Statement failed at "+Thread.currentThread().getStackTrace()[1].getLineNumber()+" with message "+e.getMessage());
				}
			}
		}
		return Command.CONTINUE;
	}
	public void writeBlockingRule(IOFSwitch sw, OFMessage msg,String network,short prefix,char proto,short port, FloodlightContext cntx){
		OFMatch match = new OFMatch();
		match.setWildcards(Wildcards.FULL.matchOn(Flag.TP_DST).matchOn(Flag.NW_SRC).withNwSrcMask(prefix).matchOn(Flag.NW_PROTO).matchOn(Flag.DL_TYPE));
		match.setDataLayerType(Ethernet.TYPE_IPv4);
		if(proto == 'T')
			match.setNetworkProtocol(IPv4.PROTOCOL_TCP);
		else
			match.setNetworkProtocol(IPv4.PROTOCOL_UDP);
		match.setNetworkSource(IPv4.toIPv4Address(network));
		match.setTransportDestination(port);
		System.out.println("wildcards are "+Integer.toBinaryString(match.getWildcards()));
		OFFlowMod flowMod = (OFFlowMod) floodlightProvider.getOFMessageFactory().getMessage(OFType.FLOW_MOD);
        flowMod.setMatch(match);
        flowMod.setCookie(LearningSwitch.LEARNING_SWITCH_COOKIE);
        flowMod.setCommand(OFFlowMod.OFPFC_ADD);
        flowMod.setIdleTimeout((short)0);
        flowMod.setHardTimeout((short)0);
        flowMod.setPriority((short)1000);
        flowMod.setBufferId(OFPacketOut.BUFFER_ID_NONE);
        flowMod.setFlags((short) (1 << 0));
        List<OFAction> actions = new ArrayList<OFAction>();
        flowMod.setActions(actions);
        try{
        	sw.write(flowMod, cntx);
        }catch(Exception e){
        	System.out.println("Write flow rule failed at"+Thread.currentThread().getStackTrace()[1].getLineNumber()+" with message "+e.getMessage());
        }
	}

}
