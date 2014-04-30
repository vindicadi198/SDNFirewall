<%-- 
    Document   : delExec
    Created on : Mar 24, 2014, 6:10:08 PM
    Author     : Bhargav
--%>

<%@page import="java.sql.PreparedStatement"%>
<%@page import="com.neproject.FirewallClient"%>
<%-- 
    Document   : editExec
    Created on : Mar 24, 2014, 6:09:59 PM
    Author     : Bhargav
--%>

<%@page import="java.util.Map"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Enumeration"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.Connection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    HttpSession ses = request.getSession();
    String src_network = request.getParameter("src_network");
    String src_prefix_length = request.getParameter("src_prefix_length");
    String dst_network = request.getParameter("dst_network");
    String dst_prefix_length = request.getParameter("dst_prefix_length");
    String protocol = request.getParameter("protocol");
    String port = request.getParameter("port");
    String priority = request.getParameter("priority");
    String tableName = request.getParameter("tableName");
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
        PreparedStatement prepStmnt = myConn.prepareStatement("DELETE FROM blocked WHERE src_network=? AND src_prefix_length=? AND dst_network=? AND dst_prefix_length=? AND protocol=? AND port=? AND priority=?");
        prepStmnt.setString(1, src_network);
        prepStmnt.setInt(2, Integer.parseInt(src_prefix_length));
        prepStmnt.setString(3, dst_network);
        prepStmnt.setInt(4, Integer.parseInt(dst_prefix_length));
        prepStmnt.setString(5, protocol);
        prepStmnt.setInt(6, Integer.parseInt(port));
        prepStmnt.setInt(7, Integer.parseInt(priority));
        String jsonData = "{\"operation\":\"D\",\"src_network\":\"" + src_network + "\",\"src_prefix_length\":\"" + src_prefix_length +"\",\"dst_network\":\"" + dst_network + "\",\"dst_prefix_length\":\"" + dst_prefix_length + "\",\"protocol\":\"" + protocol + "\",\"port\":\"" + port +"\",\"prority\":\"" + priority + "\"}\n";
        String res = client.send(jsonData);
        if (res.contains("Success")) {
            prepStmnt.executeUpdate();
        } else {
            out.print("<script> alert('Delete is " + res + "') </script>");
        }

        out.print("Deleted Successfully");

    } catch (ClassNotFoundException cnfe) {
        System.err.println("Error loading driver: " + cnfe);
    } catch (SQLException sqle) {
        System.err.println("Error connecting: " + sqle);
        out.print("<script> alert('" + sqle.toString().replace("\n", "\\\n") + "') </script>");
    }
%>
