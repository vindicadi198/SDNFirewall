<%-- 
    Document   : applySuricataRule
    Created on : Jun 25, 2014, 10:29:51 PM
    Author     : Bhargav
--%>

<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="com.neproject.FirewallClient"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.SQLException"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    if (session.getAttribute("email") == null) {
        response.sendRedirect("Signin.jsp");
    }
    System.out.println("entered toggle");

            String src_network = request.getParameter("src_network");
            String src_prefix_length = request.getParameter("src_prefix_length");
            String dst_network = request.getParameter("dst_network");
            String dst_prefix_length = request.getParameter("dst_prefix_length");
            String protocol = request.getParameter("protocol");
            String port = request.getParameter("port");
            String signature_id = request.getParameter("signature_id");
            String apply = request.getParameter("apply");
            String server = getServletContext().getInitParameter("server");
            Integer serverPort = Integer.parseInt(getServletContext().getInitParameter("port"));
            FirewallClient client = (FirewallClient) session.getAttribute("client");
            if (client == null) {
                client = new FirewallClient(server, serverPort);
                session.setAttribute("client", client);
            }

            if (src_network != null) {
                try {
                    Class.forName("org.postgresql.Driver");
                    Connection myConn = DriverManager.getConnection("jdbc:postgresql://" + getServletContext().getInitParameter("server") + ":5432/openflow", getServletContext().getInitParameter("db_user"), getServletContext().getInitParameter("db_passwd"));
                    System.out.println("jdbc:postgresql://" + getServletContext().getInitParameter("server") + ":5432/openflow");
                    PreparedStatement prepStmnt = myConn.prepareStatement("WITH temp AS (SELECT *,row_number() OVER (ORDER BY count)+1000 as priority FROM suricata NATURAL JOIN rule_count ORDER BY count ASC) SELECT * FROM temp WHERE signature_id = ?");
                    PreparedStatement toggleSuricataApply = myConn.prepareStatement("UPDATE suricata SET apply=? WHERE signature_id = ?");
                    prepStmnt.setInt(1, Integer.parseInt(signature_id));
                    toggleSuricataApply.setInt(2, Integer.parseInt(signature_id));
                    ResultSet resSet = prepStmnt.executeQuery();
                    if (resSet.next()) {
                        if (Integer.parseInt(apply) == 1) {
                            toggleSuricataApply.setInt(1, 0);
                            String jsonData = "{\"operation\":\"D\",\"src_network\":\"" + src_network + "\",\"src_prefix_length\":\"" + src_prefix_length + "\",\"dst_network\":\"" + dst_network + "\",\"dst_prefix_length\":\"" + dst_prefix_length + "\",\"protocol\":\"" + protocol + "\",\"port\":\"" + port + "\",\"priority\":\"" + resSet.getString("priority") + "\"}\n";
                            String res = client.send(jsonData);
                            if (res.contains("Success")) {
                                toggleSuricataApply.executeUpdate();
                            } else {
                                out.print("<script> alert('Error Occured') </script>");
                            }
                        } else {
                            toggleSuricataApply.setInt(1, 1);
                            String jsonData = "{\"operation\":\"I\",\"src_network\":\"" + src_network + "\",\"src_prefix_length\":\"" + src_prefix_length + "\",\"dst_network\":\"" + dst_network + "\",\"dst_prefix_length\":\"" + dst_prefix_length + "\",\"protocol\":\"" + protocol + "\",\"port\":\"" + port + "\",\"priority\":\"" + resSet.getString("priority") + "\"}\n";
                            String res = client.send(jsonData);
                            if (res.contains("Success")) {
                                toggleSuricataApply.executeUpdate();
                            } else {
                                out.print("<script> alert('Error Occured') </script>");
                            }
                        }

                    }

                    out.print("<script> alert('Inserted Successfully') </script>");
                } catch (ClassNotFoundException cnfe) {
                    System.err.println("Error loading driver: " + cnfe);
                   // out.print("<script> alert('" + cnfe.toString().replace("\n", "\\\n") + "') </script>");
                } catch (SQLException sqle) {
                    System.err.println("Error connecting: " + sqle.getMessage());
                    //out.print("<script> alert('" + sqle.toString().replace("\n", "\\\n") + "') </script>");
                }
            }
        %>
