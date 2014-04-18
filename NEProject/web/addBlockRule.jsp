<%-- 
    Document   : addBlockRule
    Created on : Apr 13, 2014, 7:51:52 PM
    Author     : Bhargav
--%>

<%@page import="com.neproject.FirewallClient"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.SQLException"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
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
            
            String network = request.getParameter("network");
            String prefix_length = request.getParameter("prefix_length");
            String protocol = request.getParameter("protocol");
            String port = request.getParameter("port");
            String server = getServletContext().getInitParameter("server");
            Integer serverPort = Integer.parseInt(getServletContext().getInitParameter("port"));
            FirewallClient client = (FirewallClient) session.getAttribute("client");
            if (client == null) {
                client = new FirewallClient(server, serverPort);
                session.setAttribute("client", client);
            }

            if (network != null) {
                try {
                    String ports[] = port.split("-");
                    Class.forName("org.postgresql.Driver");
                    Connection myConn = DriverManager.getConnection("jdbc:postgresql://"+getServletContext().getInitParameter("server")+":5432/openflow", "postgres", "iithiith");
                    System.out.println("jdbc:postgresql://"+getServletContext().getInitParameter("server")+":5432/openflow");
                    Statement stmt = myConn.createStatement();
                    if (ports.length == 2) {
                        for (int i = Integer.parseInt(ports[0]); i <= Integer.parseInt(ports[1]); i++) {
                            String jsonData = "{\"operation\":\"I\",\"network\":\"" + network + "\",\"prefix_length\":\"" + prefix_length + "\",\"protocol\":\"" + protocol + "\",\"port\":\"" + i + "\"}\n";
                            String res = client.send(jsonData);
                            if (res.contains("Success")) {
                                String query = "INSERT INTO " + getServletContext().getInitParameter("tableName") + " VALUES('" + network + "'," + prefix_length + ",'" + protocol + "'," + i + ");";
                                stmt.executeUpdate(query);
                                System.out.println(query);
                            }else{
                                out.print("<script> alert('Inserted Successfully') </script>");
                            }
                            
                        }
                    } else {
                        String jsonData = "{\"operation\":\"I\",\"network\":\"" + network + "\",\"prefix_length\":\"" + prefix_length + "\",\"protocol\":\"" + protocol + "\",\"port\":\"" + port + "\"}\n";
                            String res = client.send(jsonData);
                        if (res.contains("Success")) {
                            String query = "INSERT INTO " + getServletContext().getInitParameter("tableName") + " VALUES('" + network + "'," + prefix_length + ",'" + protocol + "'," + port + ");";
                            stmt.executeUpdate(query);
                            System.out.println(query);
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
                <input type="text" class="form-control top-elem" placeholder="Network" required="" autofocus="" name="network">
                <input type="text" class="form-control inbetween-elem" placeholder="Prefix Length" required="" name="prefix_length">
                <select id="protocol" class="form-control inbetween-elem" name="protocol">
                    <option>T</option>
                    <option>U</option>
                </select>
                <input type="text" class="form-control bottom-elem" placeholder="Port Number" required="" name="port">
                <button class="btn btn-lg btn-primary btn-block" type="submit">Block</button>
            </form>
        </div>
    </body>
</html>
