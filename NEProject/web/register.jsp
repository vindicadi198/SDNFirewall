<%-- 
    Document   : register
    Created on : Mar 18, 2014, 10:16:01 PM
    Author     : Bhargav
--%>

<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.Connection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <meta name="description" content="">
        <meta name="author" content="">
        <link rel="shortcut icon" href="http://getbootstrap.com/assets/ico/favicon.ico">
        <script src="js/jquery-2.1.0.min.js"></script>
        <script src="js/bootstrap.min.js"></script>
        <script src="js/md5Generator.js"></script>

        <title>Signin</title>

        <!-- Bootstrap core CSS -->
        <link href="css/bootstrap.min.css" rel="stylesheet">

        <!-- Custom styles for this template -->
        <link href="css/signin/register.css" rel="stylesheet">
        <script>
            function send(){
                console.log($("#password").val());
                $("#password").val(MD5Generator($("#password").val()));
                console.log($("#password").val());
            }
        </script>

    </head>
    <body> 
        <%@ include file="header.jsp" %>
        <script>
            $("a[href='register.jsp'").parent().addClass("active");
        </script>

        <div class="container">


            <%
                if (ses.getAttribute("referer") == null) {
                    ses.setAttribute("referer", request.getHeader("referer"));
                }
                response.setHeader("Referer", request.getHeader("referer"));
                System.out.println("referer is : " + request.getHeader("referer"));
                String email = request.getParameter("email");
                String password = request.getParameter("password");
                String name = request.getParameter("name");
                if (email != null) {
                    try {
                        System.out.println(password);
                        Class.forName("org.postgresql.Driver");
                        Connection myConn = DriverManager.getConnection("jdbc:postgresql://"+ getServletContext().getInitParameter("server") + ":5432/openflow", getServletContext().getInitParameter("db_user"), getServletContext().getInitParameter("db_passwd"));
                        PreparedStatement prepStmnt = myConn.prepareStatement("Insert into users values (?,?,?)");
                        ses.setAttribute("name", name);
                        ses.setAttribute("email", email);
                        System.out.println("|"+email+"|");
                        prepStmnt.setString(1, name);
                        prepStmnt.setString(2, email);
                        prepStmnt.setString(3, password);
                        System.out.println(prepStmnt.toString());
                        prepStmnt.executeUpdate();
                        prepStmnt.close();
                        myConn.close();

                        response.sendRedirect(ses.getAttribute("referer").toString());
                    } catch (ClassNotFoundException cnfe) {
                        System.err.println("Error loading driver: " + cnfe);
                    } catch (SQLException sqle) {
                        System.err.println("Error connecting: " + sqle);
                        
                        out.print("<script>alert(\""+sqle.toString().replace("\"","\\\"").replace("\n","\\n")+"\");</script>");
                    }
                }
            %>
            <form class="form-signin" role="form" method="POST" id="register-form" action="register.jsp">
                <h2 class="form-signin-heading">Please Register</h2>
                <input type="text" class="form-control top-elem" placeholder="Name" required="" autofocus=""  name="name">
                <input type="email" class="form-control inbetween-elem" placeholder="Email address" required="" name="email">
                <input type="password" id="password" class="form-control inbetween-elem" placeholder="Password" required="" name="password">
                <label class="checkbox">
                    <input type="checkbox" value="remember-me"> Remember me
                </label>
                <button class="btn btn-lg btn-primary btn-block" onclick="send()">Register</button>
            </form>
            

        </div> 
    </body>
</html>
