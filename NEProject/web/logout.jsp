<%-- 
    Document   : logout
    Created on : Mar 18, 2014, 7:56:22 AM
    Author     : Bhargav
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<% 
    session.invalidate();
    response.sendRedirect("home.jsp");
%>