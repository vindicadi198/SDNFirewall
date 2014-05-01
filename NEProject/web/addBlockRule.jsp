<%-- 
    Document   : addBlockRule
    Created on : Apr 13, 2014, 7:51:52 PM
    Author     : Bhargav
--%>

<%@page import="java.sql.PreparedStatement"%>
<%@page import="com.neproject.FirewallClient"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.SQLException"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<% 
    if(session.getAttribute("email")==null){
        response.sendRedirect("Signin.jsp");
    }
    
%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link href="css/bootstrap.min.css" rel="stylesheet">
        <link href="css/bootstrap-theme.min.css" rel="stylesheet">
        <script src="js/jquery-2.1.0.min.js"></script>
        <script src="js/bootstrap.min.js"></script>
        <link href="css/signin/register.css" rel="stylesheet">
        <title>Add Block Rule</title>
    </head>
    <body>
        <%  
            
            String src_network = request.getParameter("src_network");
            String src_prefix_length = request.getParameter("src_prefix_length");
            String dst_network = request.getParameter("dst_network");
            String dst_prefix_length = request.getParameter("dst_prefix_length");
            String protocol = request.getParameter("protocol");
            String port = request.getParameter("port");
            String priority = request.getParameter("priority");
            String server = getServletContext().getInitParameter("server");
            Integer serverPort = Integer.parseInt(getServletContext().getInitParameter("port"));
            FirewallClient client = (FirewallClient) session.getAttribute("client");
            if (client == null) {
                client = new FirewallClient(server, serverPort);
                session.setAttribute("client", client);
            }

            if (src_network != null) {
                try {
                    String ports[] = port.split("-");
                    Class.forName("org.postgresql.Driver");
                    Connection myConn = DriverManager.getConnection("jdbc:postgresql://"+getServletContext().getInitParameter("server")+":5432/openflow", getServletContext().getInitParameter("db_user"), getServletContext().getInitParameter("db_passwd"));
                    System.out.println("jdbc:postgresql://"+getServletContext().getInitParameter("server")+":5432/openflow");
                    PreparedStatement prepStmnt = myConn.prepareStatement("Insert into blocked values (?,?,?,?,?,?,?)");
                    prepStmnt.setString(1, src_network);
                    prepStmnt.setInt(2, Integer.parseInt(src_prefix_length));
                    prepStmnt.setString(3, dst_network);
                    prepStmnt.setInt(4, Integer.parseInt(dst_prefix_length));
                    prepStmnt.setString(5, protocol);
                    prepStmnt.setInt(7, Integer.parseInt(priority));
                    if (ports.length == 2) {
                        for (int i = Integer.parseInt(ports[0]); i <= Integer.parseInt(ports[1]); i++) {
                            String jsonData = "{\"operation\":\"I\",\"src_network\":\"" + src_network + "\",\"src_prefix_length\":\"" + src_prefix_length +"\",\"dst_network\":\"" + dst_network + "\",\"dst_prefix_length\":\"" + dst_prefix_length + "\",\"protocol\":\"" + protocol + "\",\"port\":\"" + i +"\",\"priority\":\"" + priority + "\"}\n";
                            String res = client.send(jsonData);
                            if (res.contains("Success")) {
                                //String query = "INSERT INTO " + getServletContext().getInitParameter("tableName") + " VALUES('" + network + "'," + prefix_length + ",'" + protocol + "'," + i + ");";
                                prepStmnt.setInt(6, i);
                                prepStmnt.executeUpdate();
                                prepStmnt.close();
                                //System.out.println(query);
                            }else{
                                out.print("<script> alert('Error Occured') </script>");
                            }
                            
                        }
                    } else {
                        String jsonData = "{\"operation\":\"I\",\"src_network\":\"" + src_network + "\",\"src_prefix_length\":\"" + src_prefix_length +"\",\"dst_network\":\"" + dst_network + "\",\"dst_prefix_length\":\"" + dst_prefix_length + "\",\"protocol\":\"" + protocol + "\",\"port\":\"" + port +"\",\"priority\":\"" + priority + "\"}\n";
                            String res = client.send(jsonData);
                        if (res.contains("Success")) {
                            //String query = "INSERT INTO " + getServletContext().getInitParameter("tableName") + " VALUES('" + network + "'," + prefix_length + ",'" + protocol + "'," + port + ");";
                            prepStmnt.setInt(6, Integer.parseInt(port));
                            prepStmnt.executeUpdate();
                            //System.out.println(query);
                                }else{
                                out.print("<script> alert('Inserted Successfully') </script>");
                            }
                        
                    }

                    out.print("<script> alert('Inserted Successfully') </script>");
                } catch (ClassNotFoundException cnfe) {
                    System.err.println("Error loading driver: " + cnfe);
                    out.print("<script> alert('" + cnfe.toString().replace("\n", "\\\n") + "') </script>");
                } catch (SQLException sqle) {
                    System.err.println("Error connecting: " + sqle.getMessage());
                    out.print("<script> alert('" + sqle.toString().replace("\n", "\\\n") + "') </script>");
                }
            }
        %>
        <div class="container">
            <%@ include file="header.jsp" %>
            <script>
                $("a[href='addBlockRule.jsp'").parent().addClass("active");
            </script>
            <form class="form-signin" role="form" method="POST" action="addBlockRule.jsp">
                <h2 class="form-signin-heading">Add Block Rule</h2>
                <input type="text" class="form-control top-elem" placeholder="Src Network" required="" autofocus="" name="src_network">
                <input type="text" class="form-control inbetween-elem" placeholder="Src Prefix Length" required="" name="src_prefix_length">
                <input type="text" class="form-control inbetween-elem" placeholder="Dst Network" required="" autofocus="" name="dst_network">
                <input type="text" class="form-control inbetween-elem" placeholder="Dst Prefix Length" required="" name="dst_prefix_length">
                <select id="protocol" class="form-control inbetween-elem" name="protocol">
                    <option>T</option>
                    <option>U</option>
                </select>
                <input type="text" class="form-control inbetween-elem" placeholder="Port Number" required="" name="port">
                <input type="text" class="form-control bottom-elem" placeholder="Priority" required="" name="priority">
                <button class="btn btn-lg btn-primary btn-block" type="submit">Block</button>
            </form>
        </div>
    </body>
</html>
