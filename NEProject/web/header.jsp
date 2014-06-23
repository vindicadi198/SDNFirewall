<%-- 
    Document   : header
    Created on : Mar 18, 2014, 6:33:59 AM
    Author     : Bhargav
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    HttpSession ses = request.getSession(true);

%>

<div class="navbar navbar-inverse navbar-fixed-top" role="navigation">
    <div class="container-fluid">
        <div class="row">
            <div class="col-lg-10 col-lg-offset-1">
                <div class="navbar-header">
                    <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
                        <span class="sr-only">Toggle navigation</span>
                        <span class="icon-bar"></span>
                        <span class="icon-bar"></span>
                        <span class="icon-bar"></span>
                    </button>
                    <a class="navbar-brand" href="#">IITH Network</a>
                </div>
                <div class="navbar-collapse collapse">
                    <ul class="nav navbar-nav">
                        <li><a href="home.jsp">Home</a></li>
                        <li><a href="addBlockRule.jsp">Add Block Rule</a></li>

                    </ul>
                    <% if (ses.getAttribute("email") == null) {%>
                    <ul class="nav navbar-right navbar-nav">
                        <li ><a href="Signin.jsp">Sign in</a></li>
                        <li><a href="register.jsp">Sign up</a></li>
                    </ul>
                    <% } else { %>
                    <ul class="nav navbar-right navbar-nav">
                        <li ><a href="profile.jsp"><% out.print(ses.getAttribute("name")); %></a></li>
                        <li><a href="logout.jsp">Log out</a></li>
                    </ul>
                    <% }%>
                </div>
            </div>
        </div>
    </div>
</div>
