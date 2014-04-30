<%-- 
    Document   : editExec
    Created on : Mar 24, 2014, 6:09:59 PM
    Author     : Bhargav
--%>

<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Enumeration"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.Connection"%>
<%@page import="com.neproject.FirewallClient"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    HttpSession ses = request.getSession();
    String old_tableName = request.getParameter("old_tableName");
    String old_src_network = request.getParameter("old_src_network");
    String old_src_prefix_length = request.getParameter("old_src_prefix_length");
    String old_dst_network = request.getParameter("old_dst_network");
    String old_dst_prefix_length = request.getParameter("old_dst_prefix_length");
    String old_protocol = request.getParameter("old_protocol");
    String old_port = request.getParameter("old_port");
    String old_priority = request.getParameter("old_priority");
    String src_network = request.getParameter("src_network");
    String src_prefix_length = request.getParameter("src_prefix_length");
    String dst_network = request.getParameter("dst_network");
    String dst_prefix_length = request.getParameter("dst_prefix_length");
    String protocol = request.getParameter("protocol");
    String port = request.getParameter("port");
    String priority = request.getParameter("priority");
    String server = getServletContext().getInitParameter("server");
    Integer serverPort = Integer.parseInt(getServletContext().getInitParameter("port"));
    FirewallClient client = (FirewallClient) ses.getAttribute("client");
    if (client == null) {
        client = new FirewallClient(server, serverPort);
        ses.setAttribute("client", client);
    }

    try {
        Class.forName("org.postgresql.Driver");
        Connection myConn = DriverManager.getConnection("jdbc:postgresql://" + getServletContext().getInitParameter("server") + ":5432/openflow", getServletContext().getInitParameter("db_user"), getServletContext().getInitParameter("db_passwd"));
        PreparedStatement prepStmnt = myConn.prepareStatement("UPDATE blocked SET src_network=? AND src_prefix_length=? AND dst_network=? AND dst_prefix_length=? AND protocol=? AND port=? AND priority=? WHERE src_network=? AND src_prefix_length=? AND dst_network=? AND dst_prefix_length=? AND protocol=? AND port=? AND priority=?");
        prepStmnt.setString(1, src_network);
        prepStmnt.setInt(2, Integer.parseInt(src_prefix_length));
        prepStmnt.setString(3, dst_network);
        prepStmnt.setInt(4, Integer.parseInt(dst_prefix_length));
        prepStmnt.setString(5, protocol);
        prepStmnt.setInt(6, Integer.parseInt(port));
        prepStmnt.setInt(7, Integer.parseInt(priority));
        prepStmnt.setString(8, old_src_network);
        prepStmnt.setString(9, old_src_prefix_length);
        prepStmnt.setString(10, old_dst_network);
        prepStmnt.setString(11, old_dst_prefix_length);
        prepStmnt.setString(12, old_protocol);
        prepStmnt.setInt(13, Integer.parseInt(old_port));
        prepStmnt.setInt(14, Integer.parseInt(old_priority));
        String jsonData = "{\"operation\":\"D\",\"src_network\":\"" + old_src_network + "\",\"src_prefix_length\":\"" + old_src_prefix_length +"\",\"dst_network\":\"" + old_dst_network + "\",\"dst_prefix_length\":\"" + old_dst_prefix_length + "\",\"protocol\":\"" + old_protocol + "\",\"port\":\"" + old_port +"\",\"prority\":\"" + old_priority + "\"}\n";
        String res1 = client.send(jsonData);
        jsonData = "{\"operation\":\"I\",\"src_network\":\"" + src_network + "\",\"src_prefix_length\":\"" + src_prefix_length +"\",\"dst_network\":\"" + dst_network + "\",\"dst_prefix_length\":\"" + dst_prefix_length + "\",\"protocol\":\"" + protocol + "\",\"port\":\"" + port +"\",\"prority\":\"" + priority + "\"}\n";
        String res2 = client.send(jsonData);
        if (res1.contains("Success") && res2.contains("Success")) {
            prepStmnt.executeUpdate();
        } else {
            out.print("<script> alert('Delete is " + res1 + " and Insert is" + res2 + "') </script>");
        }
    } catch (ClassNotFoundException cnfe) {
        System.err.println("Error loading driver: " + cnfe);
    } catch (SQLException sqle) {
        System.err.println("Error connecting: " + sqle);
        out.print("<script> alert('" + sqle.toString().replace("\n", "\\\n") + "') </script>");
    }
%>