<%-- 
    Document   : delExec
    Created on : Mar 24, 2014, 6:10:08 PM
    Author     : Bhargav
--%>

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
    String tableName = request.getParameter("tableName");
    String pkey = request.getParameter("pkey");
    String pkeyval = request.getParameter("pkeyval");
    String pkeySet[] = pkey.split(",");
    String pkeyvalSet[] = pkeyval.split(",");
    String predicate = "";
    String primarykeyvalset = "";
    Map<String, String> columnToType = new HashMap<String, String>();
    String server = getServletContext().getInitParameter("server");
    Integer serverPort = Integer.parseInt(getServletContext().getInitParameter("port"));
    FirewallClient client = (FirewallClient) ses.getAttribute("client");
    if (client == null) {
        client = new FirewallClient(server, serverPort);
        ses.setAttribute("client", client);
    }
    System.out.println("primary key set is " + primarykeyvalset);

    try {
        String network=null,prefix_length=null,protocol=null,port=null;
        Class.forName("org.postgresql.Driver");
        Connection myConn = DriverManager.getConnection("jdbc:postgresql://"+getServletContext().getInitParameter("server")+":5432/openflow", "postgres", "iithiith");
        Statement stmt = myConn.createStatement();
        String query = "SELECT * FROM " + tableName + ";";
        ResultSet resSet = stmt.executeQuery(query);
        int colCount = resSet.getMetaData().getColumnCount();
        for (int j = 1; j <= colCount; j++) {
            System.out.println(resSet.getMetaData().getColumnName(j) + " " + resSet.getMetaData().getColumnTypeName(j));
            columnToType.put(resSet.getMetaData().getColumnName(j), resSet.getMetaData().getColumnTypeName(j));
        }
        for (int pky = 0; pky < pkeySet.length; pky++) {
            if(pkeySet[pky].equals("network")){
                network=pkeyvalSet[pky];
            }else if(pkeySet[pky].equals("prefix_length")){
               prefix_length=pkeyvalSet[pky];
            }else if(pkeySet[pky].equals("protocol")){
                protocol=pkeyvalSet[pky];
            }else if(pkeySet[pky].equals("port")){
                port=pkeyvalSet[pky];
            }
            System.out.println(pky);
            if (pky == 0) {
                if (!columnToType.get(pkeySet[pky]).equals("varchar") && !columnToType.get(pkeySet[pky]).equals("date") && !columnToType.get(pkeySet[pky]).equals("bpchar")) {
                    primarykeyvalset += pkeySet[pky] + "=" + pkeyvalSet[pky] + "";
                } else {
                    primarykeyvalset += pkeySet[pky] + "='" + pkeyvalSet[pky] + "'";
                }

            } else {
                if (!columnToType.get(pkeySet[pky]).equals("varchar") && !columnToType.get(pkeySet[pky]).equals("date") && !columnToType.get(pkeySet[pky]).equals("bpchar")) {
                    primarykeyvalset += " and " + pkeySet[pky] + "=" + pkeyvalSet[pky] + "";
                } else {
                    primarykeyvalset += " and " + pkeySet[pky] + "='" + pkeyvalSet[pky] + "'";
                }

            }
        }
        String jsonData = "{\"operation\":\"D\",\"network\":\"" + network + "\",\"prefix_length\":\"" + prefix_length + "\",\"protocol\":\"" + protocol + "\",\"port\":\"" + port + "\"}\n";
        String res = client.send(jsonData);
        if (res.contains("Success")) {
            query = "DELETE FROM " + tableName + " WHERE " + primarykeyvalset + ";";
            System.out.println(query);
            stmt.executeUpdate(query);
        } else {
            out.print("<script> alert('Delete is "+res+"') </script>");
        }

        out.print("Deleted Successfully");

    } catch (ClassNotFoundException cnfe) {
        System.err.println("Error loading driver: " + cnfe);
    } catch (SQLException sqle) {
        System.err.println("Error connecting: " + sqle);
    }
%>
