<%-- 
    Document   : Signin.jsp
    Created on : Mar 17, 2014, 6:50:13 PM
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
        <script src="js/bootstrap.min.js"></script>
        <script src="js/jquery-2.1.0.min.js"></script>
        <script src="js/md5Generator.js"></script>

        <title>Signin Template for Bootstrap</title>

        <!-- Bootstrap core CSS -->
        <link href="css/bootstrap.min.css" rel="stylesheet">

        <!-- Custom styles for this template -->
        <link href="css/signin/signin.css" rel="stylesheet">
        <script>
            function send() {
                console.log($("#password").val());
                $("#password").val(MD5Generator($("#password").val()));
                console.log($("#password").val());
            }
        </script>
    </head>
    <body> 
        <%@ include file="header.jsp" %>
        <script>
            $("a[href='Signin.jsp'").parent().addClass("active");
        </script>

        <div class="container">

            <form class="form-signin" role="form" method="POST" action="Signin.jsp">
                <%
                    if (ses.getAttribute("referer") == null) {
                        ses.setAttribute("referer", request.getHeader("referer"));
                    }
                    response.setHeader("Referer", request.getHeader("referer"));
                    System.out.println("referer is : " + request.getHeader("referer"));
                    String email = request.getParameter("email");
                    String password = request.getParameter("password");
                    if (email != null) {
                        try {
                            Class.forName("org.postgresql.Driver");
                            Connection myConn = DriverManager.getConnection("jdbc:postgresql://"+ getServletContext().getInitParameter("server") + ":5432/openflow",getServletContext().getInitParameter("db_user"), getServletContext().getInitParameter("db_passwd"));
                            PreparedStatement prepStmnt = myConn.prepareStatement("select username,email,password from users where email= ? and password=?");

                            prepStmnt.setString(1, email);
                            prepStmnt.setString(2, password);
                            System.out.println(prepStmnt.toString());
                            ResultSet resSet = prepStmnt.executeQuery();
                            
                            if (resSet.next()) {

                                System.out.println(resSet.getString("username"));
                                ses.setAttribute("name", resSet.getString("username"));
                                ses.setAttribute("email", email);
                                response.sendRedirect(ses.getAttribute("referer").toString());
                                //out.println("valid!");
                            } else {
                                if (email == null && password == null) {

                                } else {
                                    out.print("<h3 class='form-signin-heading' style='color:red'>Invalid username or password</h3>");
                                }
                            }
                            prepStmnt.close();
                            myConn.close();
                        } catch (ClassNotFoundException cnfe) {
                            System.err.println("Error loading driver: " + cnfe);
                            
                        } catch (SQLException sqle) {
                            System.err.println("Error connecting: " + sqle);
                            out.print("<script>alert(\"" + sqle.toString().replace("\"", "\\\"").replace("\n", "\\n") + "\");</script>");
                        }
                    }

                %>
                <h2 class="form-signin-heading">Please sign in</h2>
                <input type="email" class="form-control" placeholder="Email address" required="" autofocus="" name="email">
                <input type="password" id="password" class="form-control" placeholder="Password" required="" name="password">
                <label class="checkbox">
                    <input type="checkbox" value="remember-me"> Remember me
                </label>
                <button class="btn btn-lg btn-primary btn-block" onclick="send()">Sign in</button>
            </form>

        </div> 
    </body>
</html>