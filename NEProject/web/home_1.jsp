<%-- 
    Document   : index
    Created on : Mar 17, 2014, 8:59:41 AM
    Author     : Bhargav
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.io.*,java.util.*,db.maintenance.ThreadClass" %>
<% 


%>
<!DOCTYPE html>
<html>
    <title>IITH Library</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <link href="css/bootstrap-theme.min.css" rel="stylesheet">
    <script src="js/jquery-2.1.0.min.js"></script>
    <script src="js/bootstrap.min.js"></script>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
</head>
<body>
    <%@ include file="header.jsp" %>
    <script>
        $("a[href='home.jsp'").parent().addClass("active");
    </script>

    <div class="container-fluid theme-showcase" role="main">

        <!-- Main jumbotron for a primary marketing message or call to action -->
        <div class="row">
            <div class="col-lg-10 col-lg-offset-1">
                <div class="row">
                    <div class="col-lg-8 col-lg-offset-2">
                        <div class="jumbotron" style="margin-top:10%">
                            <h2 align="center">IIT Hyderabad Library</h2>
                            <form class="form-group"  id="book-title">
                                <div class="col-lg-3"> </div>
                                <div class="col-lg-6">
                                    <div class="input-group">

                                        <input type="text" class="form-control" name="title">
                                        <span class="input-group-btn">
                                            <button class="btn btn-default btn-success" type="button" onclick="getbooks()">Search</button>
                                        </span>
                                    </div><!-- /input-group -->
                                </div><!-- /.col-lg-6 -->
                                <div class="col-lg-3"> </div>     
                            </form>
                        </div>
                    </div>

                </div>
                <div class="row">
                    <div class="col-lg-8 col-lg-offset-2" id="main-body">

                    </div>
                </div>
                <div class="row">
                    <div class="col-lg-8 col-lg-offset-2">
                        <div class="panel panel-default" style="visibility:hidden;" id="result_panel">
                            <div class="panel-heading" >
                                <div class="btn-group">


                                    <!-- <button type="button" class="btn btn-success" data-toggle="modal" data-target="#myModal">Edit
                                    -->
                                    <button type="button" class="btn btn-success" onclick="modalCall()">Edit
                                    </button>
                                </div>
                            </div>
                            <div class="panel-body">
                                <div id="table_data" style="padding-top:40px;overflow:auto">
                                </div>
                            </div>
                        </div>
                        <script>
                            function modalCall(elmnt, cnt, tableName) {
                                table_name = tableName;
                                console.log(elmnt.find("td"));
                                var elements = elmnt.find("td");
                                modalFormSet(elements, cnt);
                                console.log(cnt);
                                console.log(elements);
                                $('#myModal').modal();
                            }

                            function modalFormSet(elemnt, cnt) {
                                $("#edit_form").html("");
                                console.log(cnt);
                                for (var i = 0; i < cnt; i++) {
                                    if ($(elemnt).eq(i).attr("name") === "isbn_num") {
                                        console.log("primary key is " + i);
                                        pkeyval = $(elemnt).eq(i).html();
                                        console.log("primary key is " + i + " " + pkeyval);
                                    }
                                    console.log("entered loop");
                                    $("#edit_form").append('<div class="form-group clearfix">\
<label for="' + $(elemnt).eq(i).attr("name") + '" class="col-sm-4 control-label">' + $(elemnt).eq(i).attr("name") + '</label>\
<div class="col-sm-7 clearfix">\
  <input type="text" class="form-control" id="' + $(elemnt).eq(0).attr("name") + '" name="' + $(elemnt).eq(i).attr("name") + '" placeholder="' + $(elemnt).eq(i).attr("name") + '" value="' + elemnt.eq(i).html() + '" >\
</div>\
</div>');
                                }
                            }

                        </script>
                        <div class="modal fade clearfix" id="myModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
                            <div class="modal-dialog">
                                <div class="modal-content">
                                    <div class="modal-header">
                                        <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                                        <h4 class="modal-title" id="myModalLabel">Edit User Details</h4>
                                    </div>
                                    <div class="modal-body">
                                        <form class="form-horizontal" role="form" action="edit_exec.php" method="get" id="edit_form">
                                        </form>
                                    </div>
                                    <div class="modal-footer">
                                        <% if(ses.getAttribute("email")!=null) {if ( !ses.getAttribute("category").equals("Librarian")) {%>
                                        <button type="button" class="btn btn-success" onclick="showGenericReviewModal($('#edit_form'), $('#myModal'))">Add</button>
                                        <button type="button" class="btn btn-success" onclick="holdBook($('#edit_form').serializeArray()[0]['value'],<% out.print("'"+ses.getAttribute("email")+"'"); %>)" >Hold</button>

                                        <%} else {%>
                                        <button type="button" class="btn btn-success" onclick="showGenericIssueModal($('#edit_form'), $('#myModal'))">Issue</button>

                                        <% }} %>
                                        <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
                                    </div>
                                </div><!-- /.modal-content -->
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

    </div>


    <%
        Enumeration paramNames = request.getParameterNames();
        System.out.println(paramNames.toString());

        while (paramNames.hasMoreElements()) {
            String paramName = (String) paramNames.nextElement();
            out.print("<tr><td>" + paramName + "</td>\n");
            String paramValue = (String) request.getParameter(paramName);
            out.println("<td> " + paramValue + "</td></tr>\n");
        }
    %>

</body>
</html>
