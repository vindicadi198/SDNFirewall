<%-- 
    Document   : updateRules
    Created on : Jun 26, 2014, 10:03:08 AM
    Author     : Bhargav
--%>

<%-- 
    Document   : addBook
    Created on : Mar 26, 2014, 8:27:15 AM
    Author     : Bhargav
--%>

<%@ page import="java.io.*,java.util.*, javax.servlet.*" %>
<%@ page import="javax.servlet.http.*" %>
<%@ page import="org.apache.commons.fileupload.*" %>
<%@ page import="org.apache.commons.fileupload.disk.*" %>
<%@ page import="org.apache.commons.fileupload.servlet.*" %>
<%@ page import="org.apache.commons.io.output.*" %>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.Connection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    //if (session.getAttribute("email") == null) {
    //    response.sendRedirect("Signin.jsp");
    //}

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
        
        <div class="container">
            <%@ include file="header.jsp" %>
            <script>
                $("a[href='Rules.jsp'").parent().addClass("active");
            </script>

            <form class="form-signin" role="form" method="POST" enctype="multipart/form-data" action="upload.jsp">
                <h2 class="form-signin-heading">Upload Suricata File</h2>
                <input type="file" class="form-contorl bottom-elem" required="" name="rules">
                <button class="btn btn-lg btn-primary btn-block" type="submit">Upload</button>
            </form>
        </div>
    </body>
</html>
