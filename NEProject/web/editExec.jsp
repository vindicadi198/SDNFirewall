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
<%@page import="com.neproject.FirewallClient"%>
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
    String server=getServletContext().getInitParameter("server");
    Integer serverPort=Integer.parseInt(getServletContext().getInitParameter("port"));
    FirewallClient client = (FirewallClient)ses.getAttribute("client");
    if(client == null){
        client = new FirewallClient(server,serverPort);
        ses.setAttribute("client", client);
    }

    //HashMap<String,String> columnToType = Map<String,String>;
    Map<String, String> columnToType = new HashMap<String, String>();

    System.out.println("primary key set is " + primarykeyvalset);
    try {
        String network=null,prefix_length=null,protocol=null,port=null;
        String nnetwork=null,nprefix_length=null,nprotocol=null,nport=null;
        Class.forName("org.postgresql.Driver");
        Connection myConn = DriverManager.getConnection("jdbc:postgresql://"+getServletContext().getInitParameter("server")+":5432/openflow", getServletContext().getInitParameter("db_user"), getServletContext().getInitParameter("db_passwd"));
        Statement stmt = myConn.createStatement();

        String query = "SELECT * FROM " + tableName + ";";
        ResultSet resSet = stmt.executeQuery(query);
        int colCount = resSet.getMetaData().getColumnCount();
        Enumeration paramNames = request.getParameterNames();
        for (int j = 1; j <= colCount; j++) {
            System.out.println(resSet.getMetaData().getColumnName(j) + " " + resSet.getMetaData().getColumnTypeName(j));
            columnToType.put(resSet.getMetaData().getColumnName(j), resSet.getMetaData().getColumnTypeName(j));
        }
        for (int pky = 0; pky < pkeySet.length; pky++) {
            System.out.println(pky);
            if(pkeySet[pky].equals("network")){
                network=pkeyvalSet[pky];
            }else if(pkeySet[pky].equals("prefix_length")){
               prefix_length=pkeyvalSet[pky];
            }else if(pkeySet[pky].equals("protocol")){
                protocol=pkeyvalSet[pky];
            }else if(pkeySet[pky].equals("port")){
                port=pkeyvalSet[pky];
            }
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
        int cnt = 1;

        while (paramNames.hasMoreElements()) {

            String paramName = (String) paramNames.nextElement();
            //out.print("<tr><td>" + paramName + "</td>\n");
            String paramValue = request.getParameter(paramName);
            //out.println("<td> " + paramValue + "</td></tr>\n");
            if(paramName.equals("network")){
                nnetwork=paramValue;
            }else if(paramName.equals("prefix_length")){
               nprefix_length=paramValue;
            }else if(paramName.equals("protocol")){
                nprotocol=paramValue;
            }else if(paramName.equals("port")){
                nport=paramValue;
            }
            if (!paramName.equals("tableName") && !paramName.equals("pkey") && !paramName.equals("pkeyval")) {
                if (predicate.equals("")) {
                    if (!columnToType.get(paramName).equals("varchar") && !columnToType.get(paramName).equals("date") && !columnToType.get(paramName).equals("bpchar")) {
                        predicate += paramName + "=" + paramValue + "";
                    } else {
                        predicate += paramName + "='" + paramValue + "'";
                    }
                } else {
                    if (!columnToType.get(paramName).equals("varchar") && !columnToType.get(paramName).equals("date") && !columnToType.get(paramName).equals("bpchar")) {
                        predicate += " , " + paramName + "=" + paramValue + "";
                    } else {
                        predicate += " , " + paramName + "='" + paramValue + "'";
                    }
                }
                cnt++;
            }

        }
        query = "UPDATE " + tableName + " SET " + predicate + " WHERE " + primarykeyvalset + ";";
        System.out.println(query);
       stmt.executeUpdate(query);
       
       String jsonData = "{\"operation\":\"D\",\"network\":\"" + network + "\",\"prefix_length\":\"" + prefix_length + "\",\"protocol\":\"" + protocol + "\",\"port\":\"" + port + "\"}\n";
        String res1 = client.send(jsonData);
       jsonData = "{\"operation\":\"I\",\"network\":\"" + nnetwork + "\",\"prefix_length\":\"" + nprefix_length + "\",\"protocol\":\"" + nprotocol + "\",\"port\":\"" + nport + "\"}\n";
        String res2 = client.send(jsonData);
        if (res1.contains("Success") || res2.contains("Success")) {
            query = "UPDATE " + tableName + " SET " + predicate + " WHERE " + primarykeyvalset + ";";
            System.out.println(query);
            stmt.executeUpdate(query);
        } else {
            out.print("<script> alert('Delete is "+res1+" and Insert is"+res2+"') </script>");
        }

        /*colCount = resSet.getMetaData().getColumnCount();
         out.print("<table class='table table-bordered justified table-hover'>");
         while (resSet.next()) {
         out.print("<tr onclick='modalCall($(this)," + colCount + ")'>");
         for (int i = 1; i < colCount + 1; i++) {
         out.print("<td name=" + resSet.getMetaData().getColumnName(i) + ">" + resSet.getString(i) + "</td>");
         }

         out.print("</tr>");

         }
         out.print("</table>");*/

    } catch (ClassNotFoundException cnfe) {
        System.err.println("Error loading driver: " + cnfe);
    } catch (SQLException sqle) {
        System.err.println("Error connecting: " + sqle);
    }
%>