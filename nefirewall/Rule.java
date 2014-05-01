package net.floodlightcontroller.nefirewall;

import org.python.antlr.PythonParser.return_stmt_return;

public class Rule {
	public String src_network;
	public short src_prefix_length;
	public String dst_network;
	public short dst_prefix_length;
	public char protocol;
	public short port;
	public short priority;

	Rule() {

	}

	Rule(String src_network, short src_prefix_length, String dst_network,
			short dst_prefix_length, char protocol, short port, short priority) {
		this.src_network=src_network;
		this.src_prefix_length = src_prefix_length;
		this.dst_network = dst_network;
		this.dst_prefix_length = dst_prefix_length;
		this.protocol = protocol;
		this.port = port;
		this.priority = priority;

	}
	@Override
	public String toString(){
		return src_network+" "+src_prefix_length+" "+dst_network+" "+dst_prefix_length+" "+protocol+" "+port+" "+priority;
	}

}
